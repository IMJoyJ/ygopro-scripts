--A・ジェネクス・ドゥルダーク
-- 效果：
-- ①：1回合1次，以属性和这张卡相同的对方场上1只攻击表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。属性和这张卡相同的那只对方的攻击表示怪兽破坏。
function c68450517.initial_effect(c)
	-- ①：1回合1次，以属性和这张卡相同的对方场上1只攻击表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。属性和这张卡相同的那只对方的攻击表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68450517,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c68450517.descost)
	e1:SetTarget(c68450517.destg)
	e1:SetOperation(c68450517.desop)
	c:RegisterEffect(e1)
end
-- 发动的代价：检查自身本回合是否未进行攻击宣言，并适用本回合不能攻击的限制
function c68450517.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤属性与指定属性相同且处于表侧攻击表示的怪兽
function c68450517.filter(c,att)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttribute(att)
end
-- 作为效果对象的卡片合法性检查：必须在对方场上且是属性与自身相同的攻击表示怪兽
function c68450517.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and c68450517.filter(chkc,e:GetHandler():GetAttribute()) end
	-- 检查对方场上是否存在至少1只属性与自身相同的攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c68450517.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttribute()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只属性与自身相同的攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68450517.filter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttribute())
	-- 设置效果处理信息为破坏所选的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若自身在场上表侧表示且对象卡仍合法，则破坏该对象怪兽
function c68450517.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and c68450517.filter(tc,c:GetAttribute()) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
