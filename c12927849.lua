--SZW－天聖輝狼剣
-- 效果：
-- 这张卡召唤成功时，可以选择自己场上1只当作装备卡使用的名字带有「异热同心武器」的怪兽表侧守备表示特殊召唤。此外，自己的主要阶段时，手卡的这张卡可以当作装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。装备怪兽战斗破坏对方怪兽送去墓地时，可以选择自己墓地1只名字带有「异热同心武器」的怪兽加入手卡。
function c12927849.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己场上1只当作装备卡使用的名字带有「异热同心武器」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12927849,0))  --"特殊召唤"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c12927849.sptg)
	e1:SetOperation(c12927849.spop)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时，手卡的这张卡可以当作装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12927849,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(c12927849.eqtg)
	e2:SetOperation(c12927849.eqop)
	c:RegisterEffect(e2)
	-- 装备怪兽战斗破坏对方怪兽送去墓地时，可以选择自己墓地1只名字带有「异热同心武器」的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12927849,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c12927849.thcon)
	e3:SetTarget(c12927849.thtg)
	e3:SetOperation(c12927849.thop)
	c:RegisterEffect(e3)
end
-- 用于筛选满足条件的怪兽（名字带有「异热同心武器」且可以特殊召唤）
function c12927849.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x107e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标选择函数
function c12927849.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c12927849.filter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在符合条件的装备怪兽
		and Duel.IsExistingTarget(c12927849.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c12927849.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，指定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置特殊召唤效果的处理函数
function c12927849.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上（表侧守备表示）
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 用于筛选满足条件的怪兽（名字带有「希望皇 霍普」）
function c12927849.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 设置装备效果的目标选择函数
function c12927849.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12927849.eqfilter(chkc) end
	-- 检查是否有足够的魔陷区域进行装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c12927849.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c12927849.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 设置装备效果的处理函数
function c12927849.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件是否满足（区域不足、控制权不符、表示形式不符等）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c12927849.zw_equip_monster(c,tp,tc)
end
-- 装备怪兽的处理函数
function c12927849.zw_equip_monster(c,tp,tc)
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果，防止被其他装备卡装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c12927849.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制效果的判断函数
function c12927849.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 战斗破坏时触发效果的条件判断函数
function c12927849.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return ec==e:GetHandler():GetEquipTarget() and ec:IsStatus(STATUS_OPPO_BATTLE) and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 用于筛选满足条件的墓地怪兽（名字带有「异热同心武器」）
function c12927849.thfilter(c)
	return c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置回手效果的目标选择函数
function c12927849.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12927849.thfilter(chkc) end
	-- 检查墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c12927849.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c12927849.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将要加入手卡的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置回手效果的处理函数
function c12927849.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认被加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
