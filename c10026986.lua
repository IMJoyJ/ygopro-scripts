--ワーム・キング
-- 效果：
-- 这张卡可以用1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，对方场上1张卡破坏。
function c10026986.initial_effect(c)
	-- 创建效果，描述为“用1只怪兽解放上级召唤”，设置属性为不可无效和不可复制，类型为单次触发，代码为上级召唤规则，条件为c10026986.otcon，操作为c10026986.otop，值为上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10026986,0))  --"用1只怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c10026986.otcon)
	e1:SetOperation(c10026986.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 创建效果，描述为“破坏”，设置分类为破坏效果，类型为起动效果，属性为可取对象，生效范围为怪兽区，代价为c10026986.descost，目标选择为c10026986.destg，操作为c10026986.desop。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10026986,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c10026986.descost)
	e2:SetTarget(c10026986.destg)
	e2:SetOperation(c10026986.desop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数c10026986.cfilter，用于筛选卡片，要求是种族为爬虫类、带有「异虫」标记的卡牌，或者场上表侧表示的卡牌。
function c10026986.cfilter(c,tp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义条件函数c10026986.otcon，判断是否可以进行上级召唤。如果目标怪兽不存在则返回true；检查控制者和场上的爬虫类怪兽数量；并且等级大于7且祭品数量小于等于1，且存在满足条件的祭品。
function c10026986.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取符合c10026986.cfilter条件的所有怪兽。
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断目标怪兽的等级是否高于7，解放祭品的数量是否小于等于1，以及是否存在满足条件的祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 定义操作函数c10026986.otop，执行上级召唤的操作。获取符合c10026986.cfilter条件的所有怪兽；选择用于解放的怪兽；将选定的怪兽设置为素材；以REASON_SUMMON+REASON_MATERIAL原因解放选定的怪兽。
function c10026986.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取符合c10026986.cfilter条件的所有怪兽。
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从场上选择1只满足条件的怪兽作为祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤和素材的原因解放选定的祭品。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 定义代价函数c10026986.descost，用于检查或执行解放怪兽的操作。如果chk为0，则检查场上是否存在满足条件的怪兽；否则，选择1-1只满足条件的怪兽并解放。
function c10026986.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足c10026986.cfilter条件的可解放的卡牌。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c10026986.cfilter,1,nil,tp) end
	-- 从场上选择1-1张满足c10026986.cfilter条件的可解放的卡牌。
	local sg=Duel.SelectReleaseGroup(tp,c10026986.cfilter,1,1,nil,tp)
	-- 以代价的原因解放选定的卡牌。
	Duel.Release(sg,REASON_COST)
end
-- 定义目标选择函数c10026986.destg，用于选择要破坏的目标。如果chkc为真，则检查目标是否属于对方控制且在场上；如果chk为0，则检查是否存在可作为目标的卡片；否则提示玩家选择要破坏的卡牌并设置操作信息。
function c10026986.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查当前连锁中是否存在至少一张场上的卡牌可以被选为目标。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示消息，要求其选择要破坏的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1-1张满足条件的卡片作为目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前处理的连锁的操作信息，指定分类为破坏效果，目标卡组为选定的卡牌，数量为1，目标玩家为0，参数为0。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义操作函数c10026986.desop，执行破坏卡牌的操作。获取当前连锁的第一个目标卡片；如果目标卡片存在且与效果相关，则以REASON_EFFECT原因破坏该卡片。
function c10026986.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果的原因破坏目标卡片。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
