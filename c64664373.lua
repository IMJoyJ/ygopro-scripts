--共界神淵体
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以衍生物以外的对方场上1只表侧表示怪兽为对象才能发动（对方不能对应这张卡的发动把作为对象的怪兽的效果发动）。种族·属性·攻击力之内有2个以上是和作为对象的怪兽相同的1只怪兽从手卡·卡组·额外卡组效果无效特殊召唤，作为对象的怪兽的效果无效。这个效果特殊召唤的怪兽和作为对象的怪兽的卡名相同的场合，可以再把那2只里侧除外。
local s,id,o=GetID()
-- 定义卡片效果初始化流程，注册卡片发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以衍生物以外的对方场上1只表侧表示怪兽为对象才能发动（对方不能对应这张卡的发动把作为对象的怪兽的效果发动）。种族·属性·攻击力之内有2个以上是和作为对象的怪兽相同的1只怪兽从手卡·卡组·额外卡组效果无效特殊召唤，作为对象的怪兽的效果无效。这个效果特殊召唤的怪兽和作为对象的怪兽的卡名相同的场合，可以再把那2只里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义对象怪兽的过滤条件：对方场上表侧表示、未被无效的效果怪兽，且非衍生物，且我方有可对应的特召怪兽
function s.tgfilter(c,e,tp)
	-- 过滤条件：对方场上表侧表示、未被无效的效果怪兽，且不能是衍生物
	return aux.NegateEffectMonsterFilter(c) and not c:IsType(TYPE_TOKEN)
		-- 过滤条件：检查手卡、卡组、额外卡组是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,nil,e,tp,c:GetRace(),c:GetAttribute(),c:GetAttack())
end
-- 定义特殊召唤怪兽的过滤条件：种族、属性、攻击力中至少有2个与对象怪兽相同，且能特殊召唤
function s.spfilter(c,e,tp,race,att,atk)
	local res=0
	if bit.band(c:GetRace(),race)~=0 then res=res+1 end
	if bit.band(c:GetAttribute(),att)~=0 then res=res+1 end
	if c:GetAttack()==atk then res=res+1 end
	if res<2 then return false end
	-- 检查特殊召唤所需的怪兽区域空格（额外卡组怪兽需检查额外怪兽区域，手卡/卡组怪兽需检查主怪兽区域）
	return ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0) or not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp)>0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 定义效果发动的准备阶段（Target）：检查合法对象，进行取对象操作，设置操作信息，并限制对方连锁
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	-- 检查我方场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在符合条件的表侧表示怪兽作为对象
		and Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择要作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择对方场上1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（从手卡、卡组、额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND)
	-- 设置连锁限制，防止对方对应此卡的发动而发动对象怪兽的效果
	Duel.SetChainLimit(s.limit(g:GetFirst()))
end
-- 定义连锁限制的条件函数：发动效果的卡片不能是作为对象的怪兽
function s.limit(c)
	return  function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 定义效果处理阶段（Activate）：特殊召唤符合条件的怪兽并无效其效果，无效对象怪兽的效果，若卡名相同则可选择将两张卡里侧除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查我方怪兽区域是否有空位，且对象怪兽在场上表侧表示存在并仍适用于此效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local race=tc:GetRace()
		local att=tc:GetAttribute()
		local atk=tc:GetAttack()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡、卡组、额外卡组中选择1只与对象怪兽有2个以上相同属性/种族/攻击力的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,1,nil,e,tp,race,att,atk)
		local sc=g:GetFirst()
		-- 如果成功选出怪兽，则尝试将其以表侧表示特殊召唤
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效特殊召唤
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			-- 效果无效特殊召唤
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2)
			-- 完成特殊召唤的处理
			Duel.SpecialSummonComplete()
			-- 无效与对象怪兽相关的连锁
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 作为对象的怪兽的效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
			-- 作为对象的怪兽的效果无效
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			e4:SetValue(RESET_TURN_SET)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 作为对象的怪兽的效果无效
				local e5=Effect.CreateEffect(c)
				e5:SetType(EFFECT_TYPE_SINGLE)
				e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e5:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e5:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e5)
			end
			local rg=Group.FromCards(tc,sc)
			if (sc:IsCode(tc:GetCode()) or tc:IsCode(sc:GetCode())) and rg:IsExists(Card.IsAbleToRemove,2,nil,POS_FACEDOWN)
				and rg:IsExists(Card.IsLocation,2,nil,LOCATION_MZONE)
				-- 询问玩家是否将特殊召唤的怪兽和对象怪兽里侧除外
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把那2只怪兽里侧除外？"
				-- 中断当前效果处理，使后续的除外处理不与特殊召唤同时进行
				Duel.BreakEffect()
				-- 将特殊召唤的怪兽和作为对象的怪兽里侧表示除外
				Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end
