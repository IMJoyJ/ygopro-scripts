--輪廻竜サンサーラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：龙族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ②：把墓地的这张卡除外，以自己墓地1只5星以上的龙族怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以把那只怪兽上级召唤。
function c33750025.initial_effect(c)
	-- ①：龙族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c33750025.tricon)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只5星以上的龙族怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以进行那只怪兽的上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,33750025)
	-- 设置效果的发动Cost：把墓地的自身除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c33750025.thtg)
	e2:SetOperation(c33750025.thop)
	c:RegisterEffect(e2)
end
-- 判定上级召唤的怪兽是否为龙族怪兽
function c33750025.tricon(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_DRAGON) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 过滤墓地中可以加入手卡的5星以上龙族怪兽
function c33750025.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标选择与发动条件判定：以自己墓地1只5星以上的龙族怪兽为对象
function c33750025.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33750025.thfilter(chkc) end
	-- 判定自己墓地是否存在可作为对象的5星以上龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c33750025.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只5星以上的龙族怪兽作为对象
	local g=Duel.SelectTarget(tp,c33750025.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将所选对象加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：进行怪兽的通常召唤/上级召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,0,0,0)
end
-- ②效果的处理：将作为对象的龙族怪兽加入手卡，那之后可以进行该怪兽的上级召唤
function c33750025.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 将目标怪兽加入手卡并确认其已到达手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		and (tc:IsSummonable(true,nil,1) or tc:IsMSetable(true,nil,1))
		-- 询问玩家是否进行该怪兽的上级召唤
		and Duel.SelectYesNo(tp,aux.Stringid(33750025,0)) then  --"是否上级召唤？"
		-- 中断效果处理（使加入手卡与上级召唤不视为同时进行）
		Duel.BreakEffect()
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		-- 判定玩家选择表侧攻击表示召唤还是里侧守备表示放置
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 对该怪兽进行表侧攻击表示的上级召唤
			Duel.Summon(tp,tc,true,nil,1)
		else
			-- 对该怪兽进行里侧守备表示的上级放置（Set）
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end
