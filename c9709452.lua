--烈日の騎士ガイアブレイズ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
-- ②：自己·对方的战斗阶段结束时，以最多有这个回合这张卡战斗破坏的怪兽数量的自己墓地的炎属性怪兽为对象才能发动。那些怪兽加入手卡。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数，注册同调召唤手续、追加攻击效果、战斗阶段结束回收效果以及记录战破数量的辅助效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.chacon)
	e1:SetOperation(s.chaop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段结束时，以最多有这个回合这张卡战斗破坏的怪兽数量的自己墓地的炎属性怪兽为对象才能发动。那些怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 这个回合这张卡战斗破坏的怪兽数量
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
-- 在自身战斗破坏怪兽时触发，用FlagEffect的Label值累加记录本回合战斗破坏的怪兽数量。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	local ct=c:GetFlagEffectLabel(id)
	if ct then c:SetFlagEffectLabel(id,ct+1)
	else c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,1) end
end
-- 判定追加攻击效果的发动条件：自身攻击并战斗破坏对方怪兽，且自身可以继续攻击。
function s.chacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前攻击怪兽是否为自身、是否战斗破坏了对方怪兽，以及自身是否满足追加攻击的系统条件。
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
end
-- 追加攻击效果的处理函数，使自身可以再进行1次攻击。
function s.chaop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前进行攻击的怪兽（自身）可以再进行1次攻击。
	Duel.ChainAttack()
end
-- 过滤自己墓地中可以加入手卡的炎属性怪兽。
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 回收效果的发动检测与对象选择函数，选择最多等同于本回合战斗破坏怪兽数量的墓地炎属性怪兽为对象。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(id)
	-- 发动检测：检查本回合是否有战斗破坏怪兽（ct存在），且自己墓地是否存在至少1只可回收的炎属性怪兽。
	if chk==0 then return ct and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在客户端提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择最多等同于本回合战斗破坏怪兽数量（ct）的自己墓地的炎属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 设置效果处理信息，声明操作分类为将选中的卡片加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 回收效果的处理函数，将仍关系到连锁的对象怪兽加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的对象怪兽集合。
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将目标怪兽加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
