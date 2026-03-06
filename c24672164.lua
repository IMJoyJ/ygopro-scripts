--幻奏の華歌聖ブルーム・プリマ
-- 效果：
-- 「幻奏的音姬」怪兽＋「幻奏」怪兽1只以上
-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：融合召唤的这张卡被送去墓地的场合，以自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽加入手卡。
function c24672164.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足过滤条件的「幻奏的音姬」怪兽和1到127只「幻奏」怪兽作为融合素材
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x109b),aux.FilterBoolFunction(Card.IsFusionSetCard,0x9b),1,127,true)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c24672164.matcheck)
	c:RegisterEffect(e2)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：融合召唤的这张卡被送去墓地的场合，以自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24672164,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCondition(c24672164.thcon)
	e4:SetTarget(c24672164.thtg)
	e4:SetOperation(c24672164.thop)
	c:RegisterEffect(e4)
end
-- 效果作用：根据融合素材数量提升攻击力
function c24672164.matcheck(e,c)
	local ct=c:GetMaterialCount()
	-- 效果作用：提升攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ct*300)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为融合召唤且从主要怪兽区被送去墓地
function c24672164.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果作用：过滤墓地中的「幻奏」怪兽
function c24672164.filter(c)
	return c:IsSetCard(0x9b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用：选择目标怪兽加入手牌
function c24672164.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24672164.filter(chkc) end
	-- 效果作用：判断是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c24672164.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择目标怪兽
	local g=Duel.SelectTarget(tp,c24672164.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果作用：将目标怪兽加入手牌
function c24672164.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
