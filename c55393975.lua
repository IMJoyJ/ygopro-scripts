--Angelechy Destrier
local s,id,o=GetID()
-- 注册卡片的同调召唤手续及效果
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：以这张卡以外的怪兽区1只不在和这张卡相同纵列的怪兽为对象才能发动。那只怪兽表侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：怪兽区域的这张卡移动到魔法与陷阱区域的场合发动。作为永续魔法卡使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetOperation(s.flagop)
	c:RegisterEffect(e2)
	-- 连锁处理结束时触发自定义事件
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.raiseop)
	c:RegisterEffect(e3)
	-- ③：这张卡在魔法与陷阱区域作为永续魔法卡存在的场合才能发动。从卡组把1张「安琪莉琪」魔法卡加入手牌。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 记录对方在连锁中发动效果的时点标记
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	-- ④：这张卡在魔法与陷阱区域作为永续魔法卡存在，对方效果处理完毕的场合发动。给予对方500伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.damcon)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
end
-- 除外目标过滤：可以被除外且不在相同纵列
function s.rmfilter(c,g)
	return c:IsAbleToRemove() and not g:IsContains(c)
end
-- 除外目标选择：选择不在同纵列的1只怪兽作为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=c:GetColumnGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,g) and chkc~=c end
	-- 检查场上是否存在可以除外且不在相同纵列的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,g) end
	-- 发送选择要除外卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,g)
	-- 设置效果处理分类为除外1张选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果处理：将选中的怪兽表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中选中的第一目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 移动事件处理：若移动到魔陷区作为永续魔法，标记连锁或触发自定义事件
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	-- 判断当前是否处于连锁处理中
	if Duel.GetCurrentChain()>0 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	else
		-- 不在连锁中时直接触发自定义时点事件
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 连锁处理完毕事件：若存在移动标记则触发自定义事件
function s.raiseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	if c:GetFlagEffect(id+o)~=0 then
		-- 触发卡片自身的自定义时点事件
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 发动条件：卡片类型必须为永续魔法
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 检索过滤条件：字段为0x1e2的魔法卡且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索目标选择：确认卡组存在符合条件的魔法卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可检索的指定魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理分类为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：将1张指定魔法卡从卡组加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择要加入手牌卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果发动记录：对方发动效果时为卡片添加标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 伤害发动条件：作为永续魔法存在且对方发动了效果处理完毕
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS and ep~=tp and c:GetFlagEffect(id)~=0
end
-- 伤害效果处理：给予对方500点伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动的提示动画
	Duel.Hint(HINT_CARD,0,id)
	-- 给予对方500点效果伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
