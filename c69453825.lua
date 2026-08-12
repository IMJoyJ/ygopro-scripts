--剛鬼ドラゴン・オーガ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「刚鬼」魔法卡加入手卡。
-- ②：这张卡被送去墓地的场合，以自己场上1只地属性怪兽为对象才能发动。比那只怪兽攻击力低的1只「刚鬼」怪兽从自己墓地加入手卡。只要作为对象的怪兽在自己场上表侧表示存在，对方怪兽只能选择作为对象的怪兽作为攻击对象。
local s,id,o=GetID()
-- 定义卡片的初始化效果函数，包含同调召唤手续、复活限制以及①②效果的注册
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「刚鬼」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己场上1只地属性怪兽为对象才能发动。比那只怪兽攻击力低的1只「刚鬼」怪兽从自己墓地加入手卡。只要作为对象的怪兽在自己场上表侧表示存在，对方怪兽只能选择作为对象的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- 判断此卡是否通过同调召唤成功，作为①效果的发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中「刚鬼」魔法卡且能加入手牌的卡片
function s.thfilter(c)
	return c:IsSetCard(0xfc) and c:IsAbleToHand() and c:IsType(TYPE_SPELL)
end
-- ①效果的发动准备，检查卡组中是否存在可检索的「刚鬼」魔法卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段检查自己卡组中是否存在至少1张满足条件的「刚鬼」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组选择1张「刚鬼」魔法卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足条件的「刚鬼」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上表侧表示的地属性怪兽，且墓地中存在攻击力比该怪兽低并能加入手牌的「刚鬼」怪兽
function s.tgfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
		-- 检查自己墓地中是否存在攻击力低于该场上怪兽攻击力的「刚鬼」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil,c:GetAttack())
end
-- 过滤自己墓地中攻击力低于指定数值的「刚鬼」怪兽
function s.thfilter2(c,atk)
	return c:IsFaceup() and c:IsSetCard(0xfc) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
		and c:GetAttack()<atk
end
-- ②效果的发动准备，处理取对象逻辑，并设置回收的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	-- 在效果发动阶段检查自己场上是否存在符合条件的地属性怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向发动效果的玩家提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只表侧表示的地属性怪兽作为效果的对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁处理的操作信息，表示该效果会将墓地中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的实际处理：将墓地中比对象怪兽攻击力低的1只「刚鬼」怪兽加入手牌，并为对象怪兽添加“对方只能选择该怪兽作为攻击对象”的持续效果
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 向发动效果的玩家提示选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己墓地中选择1张攻击力低于对象怪兽攻击力且不受「王家长眠之谷」影响的「刚鬼」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil,tc:GetAttack())
		if g:GetCount()>0 then
			-- 将选择的墓地怪兽因效果加入玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡片进行确认
			Duel.ConfirmCards(1-tp,g)
		end
		-- 只要作为对象的怪兽在自己场上表侧表示存在，对方怪兽只能选择作为对象的怪兽作为攻击对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「刚鬼 飞龙食人魔」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
		e1:SetValue(s.atlimit)
		tc:RegisterEffect(e1,true)
	end
end
-- 限制对方怪兽的攻击目标，使其不能选择除作为对象的怪兽以外的怪兽作为攻击对象
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
