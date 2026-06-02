--破滅なる予幻視
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己的墓地·除外状态的1只「无垢者 米底乌斯」为对象才能发动。那只怪兽特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象，宣言1～10的任意等级才能发动。那只怪兽的等级直到回合结束时变成宣言的等级。
local s,id,o=GetID()
-- 初始化函数，注册①效果（特殊召唤）和②效果（改变等级）
function s.initial_effect(c)
	-- 记录卡片效果中记载了「无垢者 米底乌斯」的卡名
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
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：在墓地或除外状态、卡名为「无垢者 米底乌斯」且可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(97556336) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与目标选择（Target）函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 判定自身场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己的墓地或除外状态是否存在满足特殊召唤条件的「无垢者 米底乌斯」
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外状态的1只「无垢者 米底乌斯」作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息为：特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的实际处理（Operation）函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍存在于原本的位置，且不受「王家之谷」的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示且拥有等级的怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- ②效果的发动准备、目标选择与等级宣言（Target）函数
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	-- 判定自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示玩家选择要改变的等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要改变的等级"
	-- 让玩家宣言1～10中与当前等级不同的任意等级
	local ac=Duel.AnnounceLevel(tp,1,10,lv)
	e:SetLabel(ac)
end
-- ②效果的实际处理（Operation）函数
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的表侧表示怪兽
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
