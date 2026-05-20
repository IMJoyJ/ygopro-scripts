--宝玉獣 アンバー・マンモス
-- 效果：
-- ①：这张卡以外的自己的「宝玉兽」怪兽被选择作为攻击对象时才能发动。攻击对象转移为这张卡。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c69937550.initial_effect(c)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c69937550.repcon)
	e1:SetOperation(c69937550.repop)
	c:RegisterEffect(e1)
	-- ①：这张卡以外的自己的「宝玉兽」怪兽被选择作为攻击对象时才能发动。攻击对象转移为这张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69937550,1))  --"转移攻击目标"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c69937550.cbcon)
	e2:SetTarget(c69937550.cbtg)
	e2:SetOperation(c69937550.cbop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否在怪兽区域表侧表示被破坏
function c69937550.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将此卡作为永续魔法卡在自己的魔法与陷阱区域表侧表示放置
function c69937550.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 检查被选择作为攻击对象的怪兽是否为这张卡以外的自己场上表侧表示的「宝玉兽」怪兽
function c69937550.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and c~=bt and bt:IsFaceup() and bt:IsSetCard(0x1034) and bt:GetControler()==c:GetControler()
end
-- 检查攻击怪兽的可攻击对象中是否包含这张卡
function c69937550.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断攻击怪兽的可选择攻击对象中是否包含这张卡，作为效果发动的可行性检查
	if chk==0 then return Duel.GetAttacker():GetAttackableTarget():IsContains(e:GetHandler()) end
end
-- 将攻击对象转移为这张卡
function c69937550.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍存在于场上，且攻击怪兽不免疫此效果
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象转移为这张卡
		Duel.ChangeAttackTarget(c)
	end
end
