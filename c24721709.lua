--救魔の標
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只魔法师族效果怪兽为对象才能发动。那只怪兽加入手卡。
function c24721709.initial_effect(c)
	-- 对应效果原文：“这个卡名的卡在1回合只能发动1张。①：以自己墓地1只魔法师族效果怪兽为对象才能发动。那只怪兽加入手卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,24721709+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c24721709.target)
	e1:SetOperation(c24721709.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否满足对象条件——是魔法师族、是效果怪兽，且能够被加入手卡（没有受到“不能加入手卡”的限制）。
function c24721709.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 对象选择与发动合法性判定函数：若已有选好的对象则验证其是否为自己墓地的合法魔法师族效果怪兽；发动前检查是否存在合法对象；存在时提示玩家选择1张并登记为对象，同时设置回手牌的操作信息。
function c24721709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c24721709.filter(chkc) end
	-- 无勾选（chk==0）时，检查自己墓地是否存在至少1张满足过滤条件的魔法师族效果怪兽，以此作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c24721709.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示（HINTMSG_ATOHAND），用于后续选择对象的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的合法魔法师族效果怪兽中选择1张，并通过SelectTarget将其登记为当前连锁的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c24721709.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前操作信息：将选中的对象卡回手牌，处理数量为1，目标玩家与位置暂不指定，供时点检测和相关效果参考。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：效果结算时，先从连锁中取得对象卡，若该卡仍与效果有关联，则将其送回持有者的手卡。
function c24721709.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中被选择为对象的卡（本效果只有1张对象，因此直接取第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以“效果”为原因，将对象卡送回其持有者的手卡，即让那只怪兽加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
