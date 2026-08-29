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
	-- 设置②效果的发动代价：把墓地的这张卡除外（作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c33750025.thtg)
	e2:SetOperation(c33750025.thop)
	c:RegisterEffect(e2)
end
-- 判定条件：被解放的怪兽是龙族时，这张卡可以作为2只祭品。
function c33750025.tricon(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_DRAGON) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- ②效果的取对象过滤条件：选择自己墓地1只5星以上的龙族怪兽，且该怪兽能被加入手卡。
function c33750025.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果发动时的目标处理：检测合法目标，选择自己墓地1只5星以上龙族怪兽作为对象，并设置加入手卡和可能召唤/盖放的操作信息。
function c33750025.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33750025.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1只满足条件的5星以上龙族怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c33750025.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示选择加入手牌对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的5星以上龙族怪兽作为效果对象，并登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c33750025.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：宣言本次效果会将1张对象卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：宣言本次效果可能进行召唤/盖放（CATEGORY_SUMMON/CATEGORY_MSET）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,0,0,0)
end
-- ②效果处理：将对象龙族怪兽加入手卡；若成功且对象仍可上级召唤，则询问玩家是否进行上级召唤，并根据玩家的选择进行表侧攻击表示召唤或里侧守备表示SET。
function c33750025.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联，将其加入手卡，并确认加入手卡成功且目前在手牌中。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		and (tc:IsSummonable(true,nil,1) or tc:IsMSetable(true,nil,1))
		-- 询问玩家是否对那只怪兽进行上级召唤（选择“是”则继续）。
		and Duel.SelectYesNo(tp,aux.Stringid(33750025,0)) then  --"是否上级召唤？"
		-- 中断当前效果处理，使后续的上级召唤作为另一个效果处理进行，避免错误时点。
		Duel.BreakEffect()
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		-- 根据能否召唤/SET选择处理：若既能上级召唤又能SET，让玩家选择表示形式；选择表侧攻击表示或不能SET时直接进入召唤；否则进入SET。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 以表侧攻击表示进行那只怪兽的上级召唤（忽略通常召唤次数，至少解放1只怪兽）。
			Duel.Summon(tp,tc,true,nil,1)
		else
			-- 以里侧守备表示SET那只怪兽（忽略通常召唤次数，至少解放1只怪兽）。
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end
