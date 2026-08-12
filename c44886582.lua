--超逸融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让卡的效果发动。
-- ①：支付2000基本分，以场上1只效果怪兽为对象才能发动。和那只怪兽是等级不同并是种族·属性相同的1只怪兽从额外卡组效果无效特殊召唤。那之后，从以下效果选1个适用。
-- ●这个效果特殊召唤的怪兽和作为对象的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ●这个效果特殊召唤的怪兽送去墓地。
local s,id,o=GetID()
-- 注册「超逸融合」的发动效果e1：设定描述、效果分类（特殊召唤+融合召唤+送去墓地）、取对象属性、魔法卡发动类型、自由时点、同名卡1回合只能发动1张的誓约次数限制，并绑定cost、target、operation处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让卡的效果发动。①：支付2000基本分，以场上1只效果怪兽为对象才能发动。
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
-- 发动cost处理：确认能支付2000基本分后，支付2000基本分作为发动代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动玩家是否能支付2000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让发动玩家支付2000点基本分作为cost
	Duel.PayLPCost(tp,2000)
end
-- 对象卡过滤器：要求目标怪兽在场上表侧表示、是效果怪兽、拥有等级，且自己额外卡组存在可特殊召唤的、与其等级不同但种族·属性相同的怪兽
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
		and c:GetLevel()>0
		-- 确认额外卡组存在满足spfilter条件（与对象怪兽等级不同、种族·属性相同且可特殊召唤）的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 特殊召唤候补过滤器：要求额外卡组怪兽与对象怪兽属性相同、种族相同、有等级且等级不同，并且可以被特殊召唤、场上有可用的额外卡组怪兽出场空格
function s.spfilter(c,e,tp,tc)
	return c:IsAttribute(tc:GetAttribute())
		and c:IsRace(tc:GetRace())
		and c:GetLevel()>0
		and not c:IsLevel(tc:GetLevel())
		-- 判定该怪兽能否被这个效果特殊召唤，以及确认场上是否有能让额外卡组怪兽出场的空格
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 对象选择处理：确认场上存在可作为对象的效果怪兽，提示并选择1只作为对象，设置从额外卡组特殊召唤的操作信息，并在发动时设定连锁限制使对方不能连锁
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	-- 检查双方怪兽区域是否存在满足条件、可以成为这个效果对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 向发动玩家提示「请选择效果的对象」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动玩家从双方怪兽区域选择1只满足条件的效果怪兽作为这个效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：预告将从额外卡组特殊召唤1只怪兽，用于其他卡对这个效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设定连锁限制为不可连锁（aux.FALSE始终返回false），实现不能对应这张卡的发动让卡的效果发动
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 融合召唤候补过滤器：要求是融合怪兽、满足融合条件、融合素材不免疫这个效果，并且能以融合召唤方式特殊召唤、能以mg作为融合素材
function s.fspfilter(c,e,tp,mg,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and not mg:IsExists(Card.IsImmuneToEffect,1,nil,e)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,chkf)
end
-- 融合素材判定过滤器：判断该卡是否包含在指定的融合素材组mg中
function s.ffilter(c,mg)
	return mg:IsContains(c)
end
-- 返回附加融合素材检查函数：要求选择的融合素材组中至少包含指定的2张素材（这个效果特殊召唤的怪兽和作为对象的怪兽）
function s.fcheck(mg)
	return function(tp,sg,fc)
				return sg:IsExists(s.ffilter,2,nil,mg)
			end
end
-- 效果处理主流程：特殊召唤的怪兽效果无效化出场后，从「融合召唤」或「送去墓地」中选1个适用——前者将2只怪兽作为融合素材融合召唤，后者将特殊召唤的怪兽送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这个效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 向发动玩家提示「请选择要特殊召唤的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让发动玩家从额外卡组选择1只与对象怪兽等级不同、种族·属性相同的怪兽作为特殊召唤目标
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		if not g or g:GetCount()==0 then return end
		local fc=g:GetFirst()
		-- 若对象怪兽仍在场上，则将选择的怪兽分步特殊召唤到发动玩家场上（表侧表示），成功后继续后续处理
		if tc and Duel.SpecialSummonStep(fc,0,tp,tp,false,false,POS_FACEUP) then
			-- 和那只怪兽是等级不同并是种族·属性相同的1只怪兽从额外卡组效果无效特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			fc:RegisterEffect(e1)
			-- 效果无效特殊召唤（无效化特殊召唤怪兽在场上的效果）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			fc:RegisterEffect(e2)
			-- 完成这次分步特殊召唤，结束特殊召唤时点
			Duel.SpecialSummonComplete()
			local chkf=tp
			local mg=Group.FromCards(tc,fc)
			-- 设置附加融合素材检查，强制融合素材必须包含这个效果特殊召唤的怪兽和作为对象的怪兽这2只
			aux.FCheckAdditional=s.fcheck
			-- 检索额外卡组中能以这2只怪兽为融合素材融合召唤的融合怪兽
			local sg=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
			local b1=sg:GetCount()>0
			local b2=fc:IsAbleToGrave()
			-- 让发动玩家从「融合召唤」和「送去墓地」中选择1个适用（选项仅在满足对应条件时有效）
			local op=aux.SelectFromOptions(tp,
				{b1,aux.Stringid(id,1),1},  --"融合召唤"
				{b2,aux.Stringid(id,2),2})  --"送去墓地"
			-- 中断当前效果处理，使之后的选择适用效果视为不同时处理（那之后的处理）
			Duel.BreakEffect()
			if op==1 then
				-- 向发动玩家提示「请选择要特殊召唤的融合怪兽」
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tfc=tg:GetFirst()
				-- 让发动玩家从mg（2只指定怪兽）中选择该融合怪兽的融合素材
				local mat=Duel.SelectFusionMaterial(tp,tfc,mg,nil,chkf)
				tfc:SetMaterial(mat)
				-- 将选择的融合素材作为融合召唤的素材送去墓地
				Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使之后的融合怪兽特殊召唤视为不同时处理
				Duel.BreakEffect()
				-- 将选择的融合怪兽以融合召唤方式特殊召唤到发动玩家场上
				Duel.SpecialSummon(tfc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				tfc:CompleteProcedure()
			elseif op==2 then
				-- 将这个效果特殊召唤的怪兽送去墓地
				Duel.SendtoGrave(fc,REASON_EFFECT)
			end
		end
	end
end
