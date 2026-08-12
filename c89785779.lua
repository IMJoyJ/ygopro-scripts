--ミレニアム・アイズ・イリュージョニスト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以对方场上1只效果怪兽为对象才能发动。选自己场上1只「眼纳祭神」融合怪兽或者「纳祭之魔」把作为对象的对方的效果怪兽当作那个效果的装备卡使用来装备。这个效果在对方回合也能发动。
-- ②：场上有「眼纳祭神」融合怪兽或者「纳祭之魔」特殊召唤的场合发动。墓地的这张卡加入手卡。
function c89785779.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以对方场上1只效果怪兽为对象才能发动。选自己场上1只「眼纳祭神」融合怪兽或者「纳祭之魔」把作为对象的对方的效果怪兽当作那个效果的装备卡使用来装备。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89785779,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,89785779)
	e1:SetCost(c89785779.eqcost)
	e1:SetTarget(c89785779.eqtg)
	e1:SetOperation(c89785779.eqop)
	c:RegisterEffect(e1)
	-- ②：场上有「眼纳祭神」融合怪兽或者「纳祭之魔」特殊召唤的场合发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89785779,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,89785780)
	e2:SetCondition(c89785779.thcon)
	e2:SetTarget(c89785779.thtg)
	e2:SetOperation(c89785779.thop)
	c:RegisterEffect(e2)
end
-- ①效果的代价判定与执行：检查自身是否能从手卡丢弃，并将自身丢弃送去墓地
function c89785779.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤对方场上表侧表示、可以改变控制权的效果怪兽
function c89785779.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
-- 过滤自己场上表侧表示、未无效、且具有装备怪兽效果的「眼纳祭神」融合怪兽或「纳祭之魔」
function c89785779.eqfilter(c)
	local m=_G["c"..c:GetCode()]
	return m and c:IsFaceup() and ((c:IsSetCard(0x1110) and c:IsType(TYPE_FUSION)) or c:IsCode(64631466))
		and not c:IsDisabled() and m.can_equip_monster and m.can_equip_monster(c)
end
-- ①效果的对象判定与选择：检查魔陷区空位、对方场上的效果怪兽、自己场上的「眼纳祭神」或「纳祭之魔」，并选择对方场上1只效果怪兽作为对象
function c89785779.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c89785779.filter(chkc) and chkc~=e:GetHandler() end
	-- 在发动判定时，检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 在发动判定时，检查对方场上是否存在可以作为效果对象的表侧表示效果怪兽
		and Duel.IsExistingTarget(c89785779.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 在发动判定时，检查自己场上是否存在符合条件的「眼纳祭神」融合怪兽或「纳祭之魔」
		and Duel.IsExistingMatchingCard(c89785779.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89785779.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果的实际处理：获取作为对象的效果怪兽，让玩家选择自己场上1只符合条件的「眼纳祭神」或「纳祭之魔」，将对象怪兽作为装备卡装备给选中的怪兽
function c89785779.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的对方怪兽
	local tc1=Duel.GetFirstTarget()
	-- 提示玩家选择自己场上表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「眼纳祭神」融合怪兽或「纳祭之魔」
	local g=Duel.SelectMatchingCard(tp,c89785779.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc2=g:GetFirst()
	if not tc2 then return end
	local m=_G["c"..tc2:GetCode()]
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc1:IsControler(1-tp) then
		m.equip_monster(tc2,tp,tc1)
	end
end
-- 过滤表侧表示的「眼纳祭神」融合怪兽或「纳祭之魔」
function c89785779.thfilter(c)
	return c:IsFaceup() and ((c:IsSetCard(0x1110) and c:IsType(TYPE_FUSION)) or c:IsCode(64631466))
end
-- ②效果的发动条件：检查本次特殊召唤成功的怪兽中是否存在「眼纳祭神」融合怪兽或「纳祭之魔」
function c89785779.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c89785779.thfilter,1,nil)
end
-- ②效果的靶向判定：此效果为必发效果，在发动时设置将墓地的这张卡加入手卡的操作信息
function c89785779.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将墓地的这张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：如果这张卡仍在墓地，则将其加入手卡
function c89785779.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
