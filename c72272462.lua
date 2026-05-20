--デスピアン・クエリティス
-- 效果：
-- 「死狱乡」怪兽＋光·暗属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。除8星以上的融合怪兽外的场上的全部怪兽的攻击力直到回合结束时变成0。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从卡组选1只「死狱乡」怪兽或者「阿不思的落胤」加入手卡或特殊召唤。
function c72272462.initial_effect(c)
	-- 注册卡片脚本中提及了「阿不思的落胤」的卡片密码。
	aux.AddCodeList(c,68468459)
	c:EnableReviveLimit()
	-- 注册融合召唤素材：「死狱乡」怪兽＋光·暗属性怪兽。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x164),c72272462.matfilter,true)
	-- ①：自己·对方的主要阶段才能发动。除8星以上的融合怪兽外的场上的全部怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72272462,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,72272462)
	e1:SetCondition(c72272462.atkcon)
	e1:SetTarget(c72272462.atktg)
	e1:SetOperation(c72272462.atkop)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从卡组选1只「死狱乡」怪兽或者「阿不思的落胤」加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72272462,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,72272463)
	e2:SetCondition(c72272462.thcon)
	e2:SetTarget(c72272462.thtg)
	e2:SetOperation(c72272462.thop)
	c:RegisterEffect(e2)
end
-- 过滤融合素材：光属性或暗属性怪兽。
function c72272462.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 效果①的发动条件：自己或对方的主要阶段。
function c72272462.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤场上表侧表示且不是8星以上融合怪兽的怪兽。
function c72272462.atkfilter(c)
	return c:IsFaceup() and not (c:IsLevelAbove(8) and c:IsType(TYPE_FUSION))
end
-- 过滤满足攻击力变为0的条件且当前攻击力大于0的怪兽。
function c72272462.atkfilter1(c)
	return c72272462.atkfilter(c) and c:GetAttack()>0
end
-- 效果①的发动准备与合法性检查。
function c72272462.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足攻击力变为0条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c72272462.atkfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果①的执行：将场上所有满足条件的怪兽攻击力直到回合结束时变成0。
function c72272462.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足条件的怪兽组。
	local g=Duel.GetMatchingGroup(c72272462.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	-- 遍历所有符合条件的怪兽。
	for tc in aux.Next(g) do
		-- 攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：表侧表示的这张卡因对方的效果从自己场上离开。
function c72272462.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 过滤卡组中可以加入手卡或特殊召唤的「死狱乡」怪兽或「阿不思的落胤」。
function c72272462.thfilter(c,e,tp,check)
	return (c:IsSetCard(0x164) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459))
		and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的发动准备与合法性检查。
function c72272462.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查卡组中是否存在可以加入手卡或特殊召唤的合法怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c72272462.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check) end
end
-- 效果②的执行：从卡组选1只「死狱乡」怪兽或者「阿不思的落胤」加入手卡或特殊召唤。
function c72272462.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己场上是否有空余的怪兽区域，用于决定是否可以特殊召唤。
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c72272462.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否只能加入手卡，或者在可以特殊召唤的情况下让玩家选择加入手卡还是特殊召唤。
		if tc:IsAbleToHand() and (not (check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)) or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的怪兽。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
