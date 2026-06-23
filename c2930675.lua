--星遺物へ至る鍵
-- 效果：
-- ①：这张卡的发动时，可以从除外的自己的卡之中以1只「机界骑士」怪兽或者1张「星遗物」卡为对象。那个场合，那张卡加入手卡。
-- ②：只要自己场上有「机界骑士」怪兽存在，和那怪兽相同纵列发动的对方的陷阱卡的效果无效化。
function c2930675.initial_effect(c)
	-- ①：这张卡的发动时，可以从除外的自己的卡之中以1只「机界骑士」怪兽或者1张「星遗物」卡为对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c2930675.target)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「机界骑士」怪兽存在，和那怪兽相同纵列发动的对方的陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c2930675.discon)
	e2:SetOperation(c2930675.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断除外区的卡是否为「机界骑士」怪兽或「星遗物」卡且能加入手牌。
function c2930675.thfilter(c)
	return ((c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xfe)) and c:IsFaceup() and c:IsAbleToHand()
end
-- 处理卡的发动时的效果选择，判断是否从除外区选择卡加入手牌。
function c2930675.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c2930675.thfilter(chkc) end
	if chk==0 then return true end
	-- 检查除外区是否存在满足条件的卡。
	if Duel.IsExistingTarget(c2930675.thfilter,tp,LOCATION_REMOVED,0,1,nil)
		-- 询问玩家是否将除外的卡加入手牌。
		and Duel.SelectYesNo(tp,aux.Stringid(2930675,0)) then  --"是否把除外的卡加入手卡？"
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c2930675.activate)
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择除外区中满足条件的1张卡作为目标。
		local g=Duel.SelectTarget(tp,c2930675.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 设置操作信息，表示将选择的卡加入手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 处理效果发动时的卡加入手牌操作。
function c2930675.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断场上的「机界骑士」怪兽是否与触发陷阱卡在同一纵列。
function c2930675.cfilter(c,seq2)
	-- 获取怪兽区的序号，用于判断怪兽与陷阱卡是否在同一纵列。
	local seq1=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and c:IsSetCard(0x10c) and seq1==4-seq2
end
-- 判断连锁是否为对方陷阱卡在魔陷区发动，且场上有符合条件的「机界骑士」怪兽。
function c2930675.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁触发的位置和序号。
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return rp==1-tp and re:IsActiveType(TYPE_TRAP) and loc==LOCATION_SZONE
		-- 检查场上有无符合条件的「机界骑士」怪兽。
		and Duel.IsExistingMatchingCard(c2930675.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
-- 处理效果发动时的陷阱卡无效化操作。
function c2930675.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了「通往星遗物的钥匙」的效果。
	Duel.Hint(HINT_CARD,0,2930675)
	-- 使连锁效果无效化。
	Duel.NegateEffect(ev)
end
