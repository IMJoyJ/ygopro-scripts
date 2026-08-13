--御巫の水舞踏
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽不会被效果破坏。
-- ②：自己主要阶段才能发动。原本卡名和装备怪兽不同的1只「御巫」怪兽从手卡·卡组特殊召唤，这张卡给那只怪兽装备。那之后，这张卡装备过的怪兽回到手卡。
function c43527730.initial_effect(c)
	-- 这张卡给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c43527730.target)
	e1:SetOperation(c43527730.activate)
	c:RegisterEffect(e1)
	-- 装备怪兽（指这张卡可以装备的对象，此处为任意怪兽）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。原本卡名和装备怪兽不同的1只「御巫」怪兽从手卡·卡组特殊召唤，这张卡给那只怪兽装备。那之后，这张卡装备过的怪兽回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,43527730)
	e4:SetTarget(c43527730.sptg)
	e4:SetOperation(c43527730.spop)
	c:RegisterEffect(e4)
end
-- e1（装备魔法发动）的目标函数：判定能否发动（场上是否有表侧表示怪兽可取对象），并选择1只表侧表示怪兽作为装备对象，同时设置装备的操作信息。
function c43527730.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件判定：我方或对方怪兽区存在至少1只表侧表示怪兽（可作为此卡的装备对象）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示操作玩家：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方怪兽区选择1只表侧表示怪兽作为此卡的装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：将把这张卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- e1的操作函数：处理装备魔法发动，若这张卡和对象怪兽都仍与效果相关且对象表侧表示，则把这张卡装备给对象。
function c43527730.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 特殊召唤的过滤条件：卡名含有‘御巫’、原本卡名与被选择怪兽的原本卡名不同、且能被特殊召唤。
function c43527730.spfilter(c,e,tp,code)
	return c:IsSetCard(0x18d) and not c:IsOriginalCodeRule(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- e4（②效果）的目标函数：判断自己主要阶段能否发动（怪兽区有空位且卡组/手牌存在符合条件的‘御巫’怪兽），并设置特殊召唤与回手牌的操作信息。
function c43527730.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 发动条件之一：我方主要怪兽区有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：手卡·卡组中存在符合spfilter条件的‘御巫’怪兽可供特殊召唤（原本卡名与装备怪兽不同）。
		and Duel.IsExistingMatchingCard(c43527730.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,ec:GetOriginalCodeRule()) end
	-- 设置操作信息：预定从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息：预定将装备怪兽（ec）送回持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,ec,1,0,0)
end
-- e4的操作函数：从手卡·卡组选择1只符合条件的‘御巫’怪兽特殊召唤，将此卡装备给它，再将之前装备过的怪兽送回手卡；期间临时关闭自爆检查以避免处理中装备卡自爆。
function c43527730.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetHandler():GetEquipTarget()
	-- 处理前检查：若我方怪兽区没有空位，则直接终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示操作玩家：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只符合条件的‘御巫’怪兽（原本卡名与装备怪兽不同）。
	local g=Duel.SelectMatchingCard(tp,c43527730.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,ec:GetOriginalCodeRule())
	local tc=g:GetFirst()
	-- 关闭卡片自爆检查，避免在特殊召唤/装备交接过程中，此卡因暂时无装备对象而自爆。
	Duel.DisableSelfDestroyCheck()
	-- 若成功特殊召唤该怪兽，并且将此卡装备给它，则继续执行后续回手处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
		-- 这张卡给那只怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c43527730.eqlimit)
		c:RegisterEffect(e1)
		if ec then
			-- Duel.BreakEffect：将后续处理与前面的特殊召唤/装备处理分断，形成不同的时点，以便正确触发‘回到手卡’相关的效果。
			Duel.BreakEffect()
			-- 把之前装备的怪兽（ec）送回其持有者的手卡。
			Duel.SendtoHand(ec,nil,REASON_EFFECT)
		end
	end
	-- 恢复自爆检查（传false表示启用自爆检查），结束临时关闭状态。
	Duel.DisableSelfDestroyCheck(false)
end
-- 装备限制函数：只有效果的所有者（即刚刚特殊召唤的‘御巫’怪兽）才能装备这张卡，保证这张卡只装备给那只怪兽。
function c43527730.eqlimit(e,c)
	return e:GetOwner()==c
end
