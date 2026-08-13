--サイバー・レーザー・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。这张卡只能通过「光子发生装置」的效果特殊召唤。可以把持有这张卡攻击力以上的攻击力·守备力的1只怪兽破坏。这个效果1回合只能使用1次。
function c4162088.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡只能通过「光子发生装置」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 可以把持有这张卡攻击力以上的攻击力·守备力的1只怪兽破坏。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4162088,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c4162088.target)
	e2:SetOperation(c4162088.operation)
	c:RegisterEffect(e2)
end
-- 过滤出场上表侧表示且攻击力或守备力不低于这张卡当前攻击力的怪兽，作为可被此效果破坏的对象。
function c4162088.filter(c,atk)
	return c:IsFaceup() and (c:IsAttackAbove(atk) or c:IsDefenseAbove(atk))
end
-- 效果发动时的目标处理：若已有对象则验证其合法；在无对象时确认场上存在满足过滤条件的目标怪兽；随后提示选择1只并登记为对象，同时设置破坏的操作信息。
function c4162088.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4162088.filter(chkc,e:GetHandler():GetAttack()) end
	-- 发动合法性检查：若场上不存在任何满足条件的表侧表示怪兽，则该效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c4162088.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方怪兽区选择1只满足条件的表侧表示怪兽，将其作为本连锁的对象。
	local g=Duel.SelectTarget(tp,c4162088.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	-- 将操作信息登记为破坏所选对象，供其他卡（如星尘龙等）进行效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：若这张卡仍表侧表示且与效果关联、对象卡仍与效果关联且仍满足条件（攻击力或守备力不低于这张卡当前攻击力），则破坏对象怪兽。
function c4162088.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c4162088.filter(tc,c:GetAttack()) then
		-- 以效果原因将选中的怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
