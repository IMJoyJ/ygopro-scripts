--御巫舞踊－迷わし鳥
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽不会被效果破坏。
-- ②：自己的「御巫」怪兽进行战斗的伤害步骤结束时，以场上1张卡为对象才能发动。那张卡回到手卡。
-- ③：这张卡在墓地存在的场合，以自己墓地1只「御巫」怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c57736667.initial_effect(c)
	-- （卡片的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c57736667.target)
	e1:SetOperation(c57736667.activate)
	c:RegisterEffect(e1)
	-- （装备限制）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：自己的「御巫」怪兽进行战斗的伤害步骤结束时，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,57736667)
	e4:SetCondition(c57736667.thcon)
	e4:SetTarget(c57736667.thtg)
	e4:SetOperation(c57736667.thop)
	c:RegisterEffect(e4)
	-- ③：这张卡在墓地存在的场合，以自己墓地1只「御巫」怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,57736668)
	e5:SetTarget(c57736667.sptg)
	e5:SetOperation(c57736667.spop)
	c:RegisterEffect(e5)
end
-- 装备魔法卡发动时的效果处理（选择装备对象）
function c57736667.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送“选择要装备的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理（执行装备）
function c57736667.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判定效果②（弹回手牌）的发动条件
function c57736667.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 获取自己进行战斗的怪兽
	local a=Duel.GetBattleMonster(tp)
	return a and ec and a:IsSetCard(0x18d)
end
-- 过滤可以返回手牌的卡片
function c57736667.thfilter(c)
	return c:IsAbleToHand()
end
-- 效果②（弹回手牌）的对象选择与操作信息设置
function c57736667.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c57736667.thfilter(chkc) end
	-- 检查场上是否存在可以返回手牌的卡片
	if chk==0 then return Duel.IsExistingTarget(c57736667.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送“选择要返回手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张卡作为返回手牌的对象
	local g=Duel.SelectTarget(tp,c57736667.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②（弹回手牌）的效果处理（执行回手）
function c57736667.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的返回手牌的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以特殊召唤的「御巫」怪兽
function c57736667.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③（墓地特召并装备）的对象选择与操作信息设置
function c57736667.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57736667.spfilter(chkc,e,tp) end
	-- 检查自己的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的魔法与陷阱区域是否有空位（用于装备这张卡）
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「御巫」怪兽
		and Duel.IsExistingTarget(c57736667.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送“选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「御巫」怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c57736667.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③（墓地特召并装备）的效果处理（执行特召、除外约束及装备）
function c57736667.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的特殊召唤对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果目标怪兽仍符合条件，则将其以表侧表示特殊召唤（分解步骤）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) then
			-- 将墓地的这张卡装备给特殊召唤的怪兽
			Duel.Equip(tp,c,tc)
		end
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
