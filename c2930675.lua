--星遺物へ至る鍵
-- 效果：
-- ①：这张卡的发动时，可以从除外的自己的卡之中以1只「机界骑士」怪兽或者1张「星遗物」卡为对象。那个场合，那张卡加入手卡。
-- ②：只要自己场上有「机界骑士」怪兽存在，和那怪兽相同纵列发动的对方的陷阱卡的效果无效化。
function c2930675.initial_effect(c)
	-- ①：这张卡的发动时，可以从除外的自己的卡之中以1只「机界骑士」怪兽或者1张「星遗物」卡为对象。那个场合，那张卡加入手卡。
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
-- 检索/回收对象的选择过滤条件：要求对象是除外区中表侧表示且能加入手卡的「机界骑士」怪兽或「星遗物」卡。
function c2930675.thfilter(c)
	return ((c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xfe)) and c:IsFaceup() and c:IsAbleToHand()
end
-- ①效果的发动时点处理：若存在符合条件的除外的卡且玩家选择回收，则将本效果设为取对象回手牌效果，并让玩家选择1张对象；否则不进行任何处理。
function c2930675.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c2930675.thfilter(chkc) end
	if chk==0 then return true end
	-- 检查自己的除外区是否存在至少1张满足 thfilter 条件的卡。
	if Duel.IsExistingTarget(c2930675.thfilter,tp,LOCATION_REMOVED,0,1,nil)
		-- 若存在可选对象，则询问玩家是否要将除外的卡加入手卡，只有选择“是”才继续取对象处理。
		and Duel.SelectYesNo(tp,aux.Stringid(2930675,0)) then  --"是否把除外的卡加入手卡？"
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c2930675.activate)
		-- 向玩家显示选择提示，要求选择1张要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己的除外区选择1张满足条件的卡作为效果对象，并将其登记为当前连锁的对象。
		local g=Duel.SelectTarget(tp,c2930675.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 设置本次连锁的操作信息：将执行回手牌操作，对象为已选择的1张卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- ①效果的实际处理：若选择的对象仍然与该效果关联，则将该卡加入其持有者的手卡。
function c2930675.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第一个对象卡（即之前选择的除外区的卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将选中的卡送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数：用于判断自己场上的表侧表示「机界骑士」怪兽是否位于与某张卡相同的纵列（通过换算额外怪兽区位置）。
function c2930675.cfilter(c,seq2)
	-- 将怪兽的所在区域序号转换为对应的纵列序号，以便与陷阱卡的纵列进行对照。
	local seq1=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and c:IsSetCard(0x10c) and seq1==4-seq2
end
-- ②效果的发动条件判定：对方在魔法与陷阱区域发动陷阱卡时，若自己场上有与之相同纵列的表侧表示「机界骑士」怪兽存在，则条件成立。
function c2930675.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中陷阱卡发动的区域和所在格子序号，用于判断纵列。
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return rp==1-tp and re:IsActiveType(TYPE_TRAP) and loc==LOCATION_SZONE
		-- 检查自己场上是否存在位于该陷阱卡相同纵列的表侧表示「机界骑士」怪兽。
		and Duel.IsExistingMatchingCard(c2930675.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
-- ②效果的处理：向双方展示此卡，并无效那次陷阱卡的效果。
function c2930675.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示本卡的卡片动画，作为效果处理的提示。
	Duel.Hint(HINT_CARD,0,2930675)
	-- 使对方发动的陷阱卡的效果无效。
	Duel.NegateEffect(ev)
end
