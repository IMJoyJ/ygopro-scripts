--劫火の舟守 ゴースト・カロン
-- 效果：
-- 「劫火之舟守 幽鬼冥船夫」的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族怪兽不能特殊召唤。
-- ①：对方场上有怪兽存在，自己场上没有这张卡以外的怪兽存在的场合，以自己墓地1只融合怪兽为对象才能发动。墓地的那只怪兽和场上的这张卡除外，把持有和那2只的等级合计相同等级的1只龙族同调怪兽从额外卡组特殊召唤。
function c23379054.initial_effect(c)
	-- 「劫火之舟守 幽鬼冥船夫」的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族怪兽不能特殊召唤。①：对方场上有怪兽存在，自己场上没有这张卡以外的怪兽存在的场合，以自己墓地1只融合怪兽为对象才能发动。墓地的那只怪兽和场上的这张卡除外，把持有和那2只的等级合计相同等级的1只龙族同调怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23379054)
	e1:SetCondition(c23379054.condition)
	e1:SetCost(c23379054.cost)
	e1:SetTarget(c23379054.target)
	e1:SetOperation(c23379054.operation)
	c:RegisterEffect(e1)
	-- 设定用于检测玩家本回合是否特殊召唤过龙族以外怪兽的计数器
	Duel.AddCustomActivityCounter(23379054,ACTIVITY_SPSUMMON,c23379054.counterfilter)
end
-- 检测特殊召唤的怪兽是否为表侧表示龙族怪兽的过滤函数
function c23379054.counterfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup()
end
-- 效果发动条件判定函数（对方场上有怪兽存在且自己场上只有这张卡）
function c23379054.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上是否只有1只怪兽（即只有这张卡）
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 效果发动代价与誓约限制处理函数
function c23379054.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查玩家本回合是否特殊召唤过龙族以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(23379054,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是龙族怪兽不能特殊召唤。①：对方场上有怪兽存在，自己场上没有这张卡以外的怪兽存在的场合，以自己墓地1只融合怪兽为对象才能发动。墓地的那只怪兽和场上的这张卡除外，把持有和那2只的等级合计相同等级的1只龙族同调怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23379054.splimit)
	-- 向发动效果的玩家注册本回合不能特殊召唤龙族以外怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家特殊召唤非龙族怪兽的誓约限制函数
function c23379054.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetRace()~=RACE_DRAGON
end
-- 过滤自己墓地中可以除外的融合怪兽，且额外卡组存在可与之进行等级合计的龙族同调怪兽
function c23379054.filter1(c,e,tp,lv,mc)
	return c:IsType(TYPE_FUSION) and c:IsAbleToRemove()
		-- 检查额外卡组中是否存在可特殊召唤且持有与那2只怪兽等级合计相同等级的龙族同调怪兽
		and Duel.IsExistingMatchingCard(c23379054.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+c:GetLevel(),mc)
end
-- 过滤额外卡组中等级与合计等级相同且可特殊召唤的龙族同调怪兽
function c23379054.filter2(c,e,tp,lv,mc)
	return c:IsLevel(lv) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
		-- 检查同调怪兽是否可特殊召唤，以及玩家额外怪兽区域/主怪兽区域是否还有出场空位
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的对象选择与可否发动判定函数
function c23379054.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23379054.filter1(chkc,e,tp,c:GetLevel(),c) end
	if chk==0 then return c:IsAbleToRemove()
		-- 检查自己墓地中是否存在符合条件的融合怪兽
		and Duel.IsExistingTarget(c23379054.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c) end
	-- 提示玩家选择作为对象的卡片（除外）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只融合怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c23379054.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c:GetLevel(),c)
	g:AddCard(e:GetHandler())
	-- 设置效果处理的预估操作信息：除外2张卡（场上这张卡与墓地对象怪兽）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,tp,LOCATION_GRAVE)
	-- 设置效果处理的预估操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：除外这2只怪兽并从额外卡组特殊召唤符合等级合计条件的龙族同调怪兽
function c23379054.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象（即墓地的融合怪兽）
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lv=c:GetLevel()+tc:GetLevel()
	local g=Group.FromCards(c,tc)
	-- 将墓地的融合怪兽和场上的这张卡表侧表示除外，并判断是否成功除外了2张卡
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只等级与除外的两张卡等级合计相同的龙族同调怪兽
		local sg=Duel.SelectMatchingCard(tp,c23379054.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
		if sg:GetCount()>0 then
			-- 将选定的龙族同调怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
