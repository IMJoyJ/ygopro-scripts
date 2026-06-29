--超逸融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让卡的效果发动。
-- ①：支付2000基本分，以场上1只效果怪兽为对象才能发动。和那只怪兽是等级不同并是种族·属性相同的1只怪兽从额外卡组效果无效特殊召唤。那之后，从以下效果选1个适用。
-- ●这个效果特殊召唤的怪兽和作为对象的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ●这个效果特殊召唤的怪兽送去墓地。
local s,id,o=GetID()
-- 注册魔法卡发动、支付2000点基本分作为Cost、效果中特召与场上怪兽同种族属性但等级不同的怪兽、并在此后选择融合召唤或将该特召怪兽送墓的效果
function s.initial_effect(c)
	-- ①：支付2000基本分，以场上1只效果怪兽为对象才能发动。和那只怪兽是等级不同并是种族·属性相同的1只怪兽从额外卡组效果无效特殊召唤。那之后，从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 支付2000点生命值作为发动的代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前的生命值是否大于或等于2000点
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 从玩家生命值中扣除2000点
	Duel.PayLPCost(tp,2000)
end
-- 场上表侧表示的效果怪兽且额外卡组存在可与之搭配特殊召唤的怪兽的过滤条件
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
		and c:GetLevel()>0
		-- 要求额外卡组中必须有同属性同种族但等级不同的可特召怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 额外卡组中可用于特殊召唤的、与被选场上怪兽同属性同种族且等级不同的怪兽过滤条件
function s.spfilter(c,e,tp,tc)
	return c:IsAttribute(tc:GetAttribute())
		and c:IsRace(tc:GetRace())
		and c:GetLevel()>0
		and not c:IsLevel(tc:GetLevel())
		-- 确认该怪兽可被特殊召唤且有空闲区域
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	-- 检查双方场上是否存在符合条件的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 向玩家提示选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上符合条件的1只效果怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息为从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 锁定连锁：此卡在被作为魔法卡正常发动时锁定连锁，使对方无法对应发动任何效果
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 额外卡组中可利用上述两只怪兽作为融合素材进行融合特殊召唤的融合怪兽过滤条件
function s.fspfilter(c,e,tp,mg,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and not mg:IsExists(Card.IsImmuneToEffect,1,nil,e)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,chkf)
end
-- 确认该怪兽是否属于指定的两只怪兽材料之一
function s.ffilter(c,mg)
	return mg:IsContains(c)
end
-- 为融合召唤提供仅限使用此两只怪兽作为融合素材的素材判定校验辅助函数
function s.fcheck(mg)
	return function(tp,sg,fc)
				return sg:IsExists(s.ffilter,2,nil,mg)
			end
end
-- 特殊召唤额外卡组怪兽并令其无效，以及此后执行融合召唤或将该怪兽送墓的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中关联的作为对象的场上怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 向玩家提示选择需要从额外特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只同属性同种族但等级不同的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		if not g or g:GetCount()==0 then return end
		local fc=g:GetFirst()
		-- 执行特殊召唤步骤，若成功则进行无效化效果的处理
		if tc and Duel.SpecialSummonStep(fc,0,tp,tp,false,false,POS_FACEUP) then
			-- 注册使特殊召唤出的怪兽效果无效化的单体无效化持续效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			fc:RegisterEffect(e1)
			-- 注册在战斗或主要阶段时同样令该怪兽无法适用其效果的单体限制持续效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			fc:RegisterEffect(e2)
			-- 完成此次额外卡组怪兽的特殊召唤手续
			Duel.SpecialSummonComplete()
			local chkf=tp
			local mg=Group.FromCards(tc,fc)
			-- 将融合仅限这二只怪兽的额外判定函数注册到系统中
			aux.FCheckAdditional=s.fcheck
			-- 获取额外卡组中可以利用这两只怪兽融合出的融合怪兽
			local sg=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
			local b1=sg:GetCount()>0
			local b2=fc:IsAbleToGrave()
			-- 由系统根据当前的可能选项提示玩家选择“融合召唤”或“送去墓地”
			local op=aux.SelectFromOptions(tp,
				{b1,aux.Stringid(id,1),1},  --"融合召唤"
				{b2,aux.Stringid(id,2),2})  --"送去墓地"
			-- 在特召成功后切断效果连锁以处理被选中的动作选项
			Duel.BreakEffect()
			if op==1 then
				-- 若选择融合召唤，提示玩家选择需要特殊召唤的融合怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tfc=tg:GetFirst()
				-- 选择由场上对象与该特召怪兽构成的融合素材怪兽组合
				local mat=Duel.SelectFusionMaterial(tp,tfc,mg,nil,chkf)
				tfc:SetMaterial(mat)
				-- 将这两只融合素材怪兽送入墓地以进行融合召唤
				Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 素材送墓后切断连锁以执行后续融合特殊召唤
				Duel.BreakEffect()
				-- 将选中的融合怪兽以表侧表示当作融合召唤特殊召唤到场上
				Duel.SpecialSummon(tfc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				tfc:CompleteProcedure()
			elseif op==2 then
				-- 若选择“送去墓地”，则直接将该特殊召唤出的额外怪兽送去墓地
				Duel.SendtoGrave(fc,REASON_EFFECT)
			end
		end
	end
end
