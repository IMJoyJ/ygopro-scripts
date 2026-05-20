--邪王トラカレル
-- 效果：
-- ①：这张卡上级召唤成功的场合才能发动。攻击力合计最多到为这张卡的上级召唤而解放的怪兽的原本攻击力以下为止，选对方场上的表侧表示怪兽任意数量破坏。
function c82319644.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合才能发动。攻击力合计最多到为这张卡的上级召唤而解放的怪兽的原本攻击力以下为止，选对方场上的表侧表示怪兽任意数量破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82319644,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c82319644.descon)
	e1:SetTarget(c82319644.destg)
	e1:SetOperation(c82319644.desop)
	c:RegisterEffect(e1)
	-- 为这张卡的上级召唤而解放的怪兽的原本攻击力
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c82319644.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 判断此卡是否上级召唤成功，且解放了怪兽
function c82319644.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:GetMaterialCount()>0
end
-- 过滤对方场上表侧表示且攻击力在解放怪兽原本攻击力总和以下的怪兽
function c82319644.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果①的发动准备，检查是否存在可破坏的怪兽并设置破坏的操作信息
function c82319644.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetLabel()
	-- 在发动时，检查对方场上是否存在至少1只表侧表示且攻击力在解放怪兽原本攻击力总和以下的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82319644.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 获取对方场上所有满足破坏条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c82319644.desfilter,tp,0,LOCATION_MZONE,nil,atk)
	-- 设置破坏的操作信息，将符合条件的怪兽组作为预期的破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 筛选函数，用于确保选取的怪兽组的攻击力合计不超过解放怪兽的原本攻击力总和
function c82319644.fselect(g,atk)
	return g:GetSum(Card.GetAttack)<=atk
end
-- 效果①的实际处理，让玩家选择任意数量攻击力合计在限制范围内的对方表侧表示怪兽并破坏
function c82319644.desop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	-- 获取当前对方场上所有满足破坏条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c82319644.desfilter,tp,0,LOCATION_MZONE,nil,atk)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:SelectSubGroup(tp,c82319644.fselect,false,1,g:GetCount(),atk)
	-- 对选中的怪兽进行闪烁提示，向双方玩家展示
	Duel.HintSelection(dg)
	-- 因效果破坏选中的怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end
-- 素材检查函数，计算上级召唤解放的怪兽的原本攻击力总和，并将其保存在效果e1中
function c82319644.valcheck(e,c)
	local atk=0
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	while tc do
		atk=atk+math.max(tc:GetTextAttack(),0)
		tc=g:GetNext()
	end
	e:GetLabelObject():SetLabel(atk)
end
