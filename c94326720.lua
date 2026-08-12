--破滅なる予幻視
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己的墓地·除外状态的1只「无垢者 米底乌斯」为对象才能发动。那只怪兽特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象，宣言1～10的任意等级才能发动。那只怪兽的等级直到回合结束时变成宣言的等级。
local s,id,o=GetID()
-- 卡片效果注册与初始化函数
function s.initial_effect(c)
	-- 在卡片关联代码列表中添加「无垢者 米底乌斯」的卡片密码
	aux.AddCodeList(c,97556336)
	-- ①：以自己的墓地·除外状态的1只「无垢者 米底乌斯」为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象，宣言1～10的任意等级才能发动。那只怪兽的等级直到回合结束时变成宣言的等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变等级"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 把墓地的这张卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 效果①特殊召唤对象的过滤条件（墓地或除外区的「无垢者 米底乌斯」）
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(97556336) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择（Target）函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 效果发动的可行性检测：检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己墓地或除外区是否存在至少1只满足特殊召唤条件的「无垢者 米底乌斯」
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地或除外区选择1只满足条件的「无垢者 米底乌斯」作为效果对象（取对象）
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤1个怪兽对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（Operation）函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与本效果处理的连锁相关联（且不受王家长眠之谷的影响）
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②等级变更对象的过滤条件（自己场上表侧表示且具有等级的怪兽）
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 效果②的发动准备与目标选择（Target）函数
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	-- 效果发动的可行性检测：自己场上是否存在满足改变等级条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为等级改变的对象（取对象）
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示玩家选择要改变的等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要改变的等级"
	-- 让玩家宣言一个1至10级中除当前等级以外的等级
	local ac=Duel.AnnounceLevel(tp,1,10,lv)
	e:SetLabel(ac)
end
-- 效果②的效果处理（Operation）函数
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	local lv=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToChain() and not tc:IsLevel(lv) then
		-- 那只怪兽的等级直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
