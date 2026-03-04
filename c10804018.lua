--粛声なる竜神サフィラ
-- 效果：
-- 「肃声之祝福」降临
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡仪式召唤的场合，若自己的场上或墓地有「肃声的祈祷者 理」存在则能发动。自己抽2张。那之后，选自己1张手卡丢弃。
-- ②：战士族·龙族而光属性的仪式怪兽进行战斗的攻击宣言时才能发动。对方手卡随机1张丢弃。
-- ③：对方结束阶段才能发动。从自己墓地把1只光属性怪兽加入手卡。
function c10804018.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合，若自己的场上或墓地有「肃声的祈祷者 理」存在则能发动。自己抽2张。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10804018,0))  --"抽卡并丢弃手卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10804018)
	e1:SetCondition(c10804018.drcon)
	e1:SetTarget(c10804018.drtg)
	e1:SetOperation(c10804018.drop)
	c:RegisterEffect(e1)
	-- ②：战士族·龙族而光属性的仪式怪兽进行战斗的攻击宣言时才能发动。对方手卡随机1张丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10804018,1))  --"丢弃对方手卡"
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10804019)
	e2:SetCondition(c10804018.hscon)
	e2:SetTarget(c10804018.hstg)
	e2:SetOperation(c10804018.hsop)
	c:RegisterEffect(e2)
	-- ③：对方结束阶段才能发动。从自己墓地把1只光属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10804018,2))  --"回收光属性怪兽"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,10804020)
	e3:SetCondition(c10804018.thcon)
	e3:SetTarget(c10804018.thtg)
	e3:SetOperation(c10804018.thop)
	c:RegisterEffect(e3)
end
-- 用于判断场上或墓地是否存在「肃声的祈祷者 理」
function c10804018.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(25801745)
end
-- 效果①的发动条件：这张卡是仪式召唤成功
function c10804018.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果①的发动时的处理：检查是否满足发动条件并设置效果处理信息
function c10804018.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①的发动条件检查：确认自己场上或墓地有「肃声的祈祷者 理」且可以抽2张卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10804018.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果①的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果①的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置效果①的处理信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置效果①的处理信息为丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的发动后处理：执行抽卡和丢弃手卡操作
function c10804018.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行抽2张卡的效果，若成功则继续处理
	if Duel.Draw(p,2,REASON_EFFECT)==2 then
		-- 将当前玩家的手卡洗牌
		Duel.ShuffleHand(p)
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 丢弃当前玩家1张手卡
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 用于判断是否为战士族·龙族且光属性的仪式怪兽
function c10804018.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR)) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果②的发动条件：攻击宣言时，攻击怪兽或被攻击怪兽满足条件
function c10804018.hscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return c10804018.filter(a) or (d and c10804018.filter(d))
end
-- 效果②的发动时的处理：检查是否满足发动条件并设置效果处理信息
function c10804018.hstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②的发动条件检查：确认对方手牌数量大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置效果②的处理信息为丢弃对方1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 效果②的发动后处理：执行丢弃对方手卡操作
function c10804018.hsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选择的对方手卡送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
-- 效果③的发动条件：当前不是自己的回合
function c10804018.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果③的发动条件检查：确认当前回合玩家不是自己
	return Duel.GetTurnPlayer()~=tp
end
-- 用于判断墓地是否存在光属性怪兽
function c10804018.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果③的发动时的处理：检查是否满足发动条件并设置效果处理信息
function c10804018.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果③的发动条件检查：确认自己墓地有光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10804018.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果③的处理信息为从墓地将1只光属性怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的发动后处理：执行将墓地光属性怪兽加入手卡操作
function c10804018.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择从墓地将怪兽加入手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从墓地选择1只光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c10804018.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
