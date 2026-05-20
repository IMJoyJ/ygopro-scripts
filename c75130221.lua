--コード・ラジエーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽攻击力变成0，效果无效化。场上的这张卡为素材的场合这个效果的对象可以变成2只。
function c75130221.initial_effect(c)
	-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,75130221)
	e1:SetValue(c75130221.matval)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽攻击力变成0，效果无效化。场上的这张卡为素材的场合这个效果的对象可以变成2只。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75130221,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,75130222)
	e3:SetCondition(c75130221.discon)
	e3:SetTarget(c75130221.distg)
	e3:SetOperation(c75130221.disop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上的电子界族怪兽
function c75130221.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 过滤条件：手卡中的这张卡本身
function c75130221.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(75130221)
end
-- 判定手卡中的这张卡能否作为「码语者」怪兽连接召唤的素材（必须以自己场上的电子界族怪兽为素材，且不能同时将多张手卡的此卡作为素材）
function c75130221.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(c75130221.mfilter,1,nil,tp) and not mg:IsExists(c75130221.exmfilter,1,nil)
end
-- 判定是否作为「码语者」怪兽的连接素材从手卡或场上送去墓地，若从场上送去墓地则将Label设为1以允许选择2个对象
function c75130221.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(0)
	if c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x101) then
		if c:IsPreviousLocation(LOCATION_ONFIELD) then
			e:SetLabel(1)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(75130221,1))  --"从场上送去墓地"
		end
		return true
	else
		return false
	end
end
-- 过滤条件：对方场上表侧表示且攻击力大于0或效果未被无效的怪兽
function c75130221.disfilter(c)
	-- 判定卡片是否表侧表示，且攻击力大于0或可以被无效化
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 效果②的选择对象阶段：根据素材来源（手卡1只，场上最多2只）选择对方场上的表侧表示怪兽
function c75130221.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c75130221.disfilter(chkc) end
	-- 判定对方场上是否存在至少1只符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c75130221.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只（若场上为素材则最多2只）对方场上的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c75130221.disfilter,tp,0,LOCATION_MZONE,1,1+e:GetLabel(),nil)
end
-- 效果②的执行阶段：使选择的怪兽攻击力变成0，且效果无效化
function c75130221.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 遍历所有被选择的对象怪兽
	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 那只怪兽攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使与该怪兽相关的连锁效果无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 效果无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
