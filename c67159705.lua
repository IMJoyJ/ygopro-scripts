--アーマード・サイバーン
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只需以「电子龙」为素材的融合怪兽或者「电子龙」为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：1回合1次，以场上1只表侧表示怪兽为对象才能发动。装备怪兽的攻击力下降1000，作为对象的表侧表示怪兽破坏。
function c67159705.initial_effect(c)
	-- 为卡片注册同盟怪兽的标准效果，并指定装备限制过滤函数
	aux.EnableUnionAttribute(c,c67159705.filter)
	-- ②：1回合1次，以场上1只表侧表示怪兽为对象才能发动。装备怪兽的攻击力下降1000，作为对象的表侧表示怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(67159705,2))  --"装备怪兽的攻击力下降1000，场上表侧表示存在的1只怪兽破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c67159705.destg)
	e5:SetOperation(c67159705.desop)
	c:RegisterEffect(e5)
end
-- 定义同盟装备对象的过滤函数
function c67159705.filter(c)
	-- 筛选卡名为「电子龙」的怪兽，或者以「电子龙」为素材的融合怪兽
	return c:IsCode(70095154) or c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,70095154)
end
-- 过滤场上表侧表示怪兽的条件函数
function c67159705.desfilter(c)
	return c:IsFaceup()
end
-- 效果②的发动检测，确认自身有装备怪兽、装备怪兽攻击力不低于1000且场上有可选择的表侧表示怪兽
function c67159705.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c67159705.desfilter(chkc) end
	if chk==0 then return e:GetHandler():GetEquipTarget() and e:GetHandler():GetEquipTarget():GetAttack()>=1000
		-- 检测场上是否存在可以作为效果对象的表侧表示怪兽
		and Duel.IsExistingTarget(c67159705.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67159705.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，准备破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理，使装备怪兽攻击力下降1000，并破坏作为对象的怪兽
function c67159705.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=c:GetEquipTarget()
	if ec:GetAttack()<1000 then return end
	-- 装备怪兽的攻击力下降1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)
	-- 获取发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not ec:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 将作为对象的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
