--ストライカー・ドラゴン
-- 效果：
-- 4星以下的龙族怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「旋转引导扇区」加入手卡。
-- ②：以自己场上1只表侧表示怪兽和自己墓地1只「弹丸」怪兽为对象才能发动。作为对象的场上的怪兽破坏，作为对象的墓地的怪兽加入手卡。
function c73539069.initial_effect(c)
	-- 注册卡片关联密码（旋转引导扇区），用于卡片效果文本提及卡名的相关检测。
	aux.AddCodeList(c,36668118)
	-- 添加连接召唤手续，需要1只满足过滤条件的怪兽作为素材。
	aux.AddLinkProcedure(c,c73539069.mfilter,1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「旋转引导扇区」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73539069,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,73539069)
	e1:SetCondition(c73539069.thcon1)
	e1:SetTarget(c73539069.thtg1)
	e1:SetOperation(c73539069.thop1)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽和自己墓地1只「弹丸」怪兽为对象才能发动。作为对象的场上的怪兽破坏，作为对象的墓地的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73539069,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,73539070)
	e2:SetTarget(c73539069.thtg2)
	e2:SetOperation(c73539069.thop2)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：4星以下的龙族怪兽。
function c73539069.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_DRAGON)
end
-- 效果①的发动条件：这张卡连接召唤成功。
function c73539069.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的检索过滤条件：卡名为「旋转引导扇区」且能加入手卡。
function c73539069.thfilter1(c)
	return c:IsCode(36668118) and c:IsAbleToHand()
end
-- 效果①的发动准备与可行性检查，设置操作信息为从卡组将1张卡加入手卡。
function c73539069.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张「旋转引导扇区」。
	if chk==0 then return Duel.IsExistingMatchingCard(c73539069.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1张「旋转引导扇区」加入手卡并给对方确认。
function c73539069.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「旋转引导扇区」。
	local g=Duel.SelectMatchingCard(tp,c73539069.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的回收过滤条件：墓地的「弹丸」怪兽且能加入手卡。
function c73539069.thfilter2(c)
	return c:IsSetCard(0x102) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备与可行性检查，选择场上的表侧表示怪兽和墓地的「弹丸」怪兽作为对象。
function c73539069.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己墓地是否存在至少1只「弹丸」怪兽。
		and Duel.IsExistingTarget(c73539069.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「弹丸」怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,c73539069.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为破坏选择的场上怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置操作信息为将选择的墓地怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- 效果②的效果处理：破坏作为对象的场上怪兽，若破坏成功，则将作为对象的墓地怪兽加入手卡。
function c73539069.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的两个对象卡并进行排序。
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 检查场上怪兽是否仍适用效果并将其破坏，若破坏成功且墓地怪兽仍适用效果则继续处理。
	if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2:IsRelateToEffect(e) then
		-- 将作为对象的墓地怪兽因效果加入手卡。
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
	end
end
