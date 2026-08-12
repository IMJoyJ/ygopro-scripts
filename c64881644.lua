--幻奏の歌姫ルフラン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己场上1只「幻奏」融合怪兽为对象才能发动。从卡组把1只「幻奏」怪兽送去墓地，作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×200。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻奏的歌姬 勒弗兰」以外的1只「幻奏」怪兽加入手卡。
-- ②：这张卡在额外卡组表侧存在的状态，自己场上有「幻奏」融合怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
function c64881644.initial_effect(c)
	-- 为怪兽卡添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：以自己场上1只「幻奏」融合怪兽为对象才能发动。从卡组把1只「幻奏」怪兽送去墓地，作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×200。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(64881644,0))
	e0:SetCategory(CATEGORY_ATKCHANGE)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCountLimit(1,64881644)
	e0:SetTarget(c64881644.atktg)
	e0:SetOperation(c64881644.atkop)
	c:RegisterEffect(e0)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻奏的歌姬 勒弗兰」以外的1只「幻奏」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64881644,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,64881645)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c64881644.thtg)
	e1:SetOperation(c64881644.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在额外卡组表侧存在的状态，自己场上有「幻奏」融合怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64881644,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,64881646)
	e3:SetCondition(c64881644.pencon)
	e3:SetTarget(c64881644.pentg)
	e3:SetOperation(c64881644.penop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以送去墓地的「幻奏」怪兽
function c64881644.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9b) and c:IsAbleToGrave()
end
-- 过滤自己场上表侧表示的「幻奏」融合怪兽
function c64881644.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and c:IsFaceup()
end
-- 灵摆效果的发动准备与目标选择
function c64881644.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c64881644.filter(chkc) end
	-- 检查场上是否存在可作为对象的「幻奏」融合怪兽，以及卡组中是否存在可送去墓地的「幻奏」怪兽
	if chk==0 then return Duel.IsExistingTarget(c64881644.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(c64881644.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「幻奏」融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64881644.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为改变攻击力
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
	-- 设置当前连锁的操作信息为从卡组将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的处理（送墓并提升攻击力）
function c64881644.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只符合条件的「幻奏」怪兽
	local tg=Duel.SelectMatchingCard(tp,c64881644.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 将选择的怪兽送去墓地，并确认其成功到达墓地
	if tg and Duel.SendtoGrave(tg,REASON_COST)~=0 and tg:IsLocation(LOCATION_GRAVE) then
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×200
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_UPDATE_ATTACK)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e0:SetValue(tg:GetLevel()*200)
			tc:RegisterEffect(e0)
		end
	end
end
-- 过滤卡组中「幻奏的歌姬 勒弗兰」以外的「幻奏」怪兽
function c64881644.thfilter(c)
	return not c:IsCode(64881644) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9b) and c:IsAbleToHand()
end
-- 怪兽效果①的发动准备
function c64881644.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手卡的「幻奏」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64881644.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的处理（从卡组检索并确认）
function c64881644.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的「幻奏」怪兽
	local g=Duel.SelectMatchingCard(tp,c64881644.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上特殊召唤成功的表侧表示「幻奏」融合怪兽
function c64881644.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and c:IsControler(tp)
end
-- 怪兽效果②的发动条件判断
function c64881644.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and eg:IsExists(c64881644.cfilter,1,nil,tp)
end
-- 怪兽效果②的发动准备
function c64881644.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否存在空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的处理（将自身放置在自己的灵摆区域）
function c64881644.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍受效果影响，且灵摆区域是否有空位
	if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		-- 将此卡在自己的灵摆区域表侧表示放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
