--魔鍵変鬼－トランスフルミネ
-- 效果：
-- 「魔键」调整＋调整以外的通常怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：作为这张卡的同调素材的怪兽的属性是2种类以上的场合才能发动。从卡组选1张「魔键」魔法·陷阱卡在自己的魔法与陷阱区域盖放。
-- ③：持有和自己墓地的其中任意种的怪兽相同属性的怪兽由对方召唤·特殊召唤的场合才能发动。那些怪兽破坏。
function c69522668.initial_effect(c)
	-- 设定同调召唤的手续：需要「魔键」调整怪兽作为调整，以及通常怪兽作为调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x165),aux.NonTuner(aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL)),1)
	c:EnableReviveLimit()
	-- ②：作为这张卡的同调素材的怪兽的属性是2种类以上的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c69522668.matcon)
	e1:SetOperation(c69522668.matop)
	c:RegisterEffect(e1)
	-- 作为这张卡的同调素材的怪兽的属性是2种类以上的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetLabelObject(e1)
	e2:SetValue(c69522668.valcheck)
	c:RegisterEffect(e2)
	-- ①：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：作为这张卡的同调素材的怪兽的属性是2种类以上的场合才能发动。从卡组选1张「魔键」魔法·陷阱卡在自己的魔法与陷阱区域盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69522668,0))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,69522668)
	e4:SetCondition(c69522668.setcon)
	e4:SetTarget(c69522668.settg)
	e4:SetOperation(c69522668.setop)
	c:RegisterEffect(e4)
	-- ③：持有和自己墓地的其中任意种的怪兽相同属性的怪兽由对方召唤·特殊召唤的场合才能发动。那些怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(69522668,1))  --"破坏和自己墓地怪兽相同属性的怪兽"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,69522669)
	e5:SetCondition(c69522668.descon)
	e5:SetTarget(c69522668.destg)
	e5:SetOperation(c69522668.desop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
end
-- 检查这张卡是否是通过同调召唤特殊召唤，且同调素材的属性在2种类以上
function c69522668.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 给自身注册一个Flag，并添加客户端提示，表示其同调素材属性在2种类以上
function c69522668.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(69522668,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(69522668,2))  --"同调素材的怪兽的属性是2种类以上"
end
-- 过滤属性大于0（即拥有有效属性）的卡片
function c69522668.attfilter(c,rc)
	return c:GetAttribute()>0
end
-- 检查同调素材的属性种类是否在2种以上，并将结果保存在e1的Label中
function c69522668.valcheck(e,c)
	local mg=c:GetMaterial()
	local fg=mg:Filter(c69522668.attfilter,nil,c)
	if fg:GetClassCount(Card.GetAttribute)>=2 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查自身是否带有同调素材属性在2种类以上的Flag
function c69522668.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(69522668)~=0
end
-- 过滤卡组中可以盖放的「魔键」魔法·陷阱卡（排除场地魔法）
function c69522668.setfilter(c)
	return c:IsSetCard(0x165) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSSetable()
end
-- 盖放效果的靶子函数，检查卡组中是否存在可盖放的「魔键」魔法·陷阱卡
function c69522668.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「魔键」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69522668.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的执行函数，从卡组选择1张「魔键」魔法·陷阱卡在自己的魔法与陷阱区域盖放
function c69522668.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「魔键」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c69522668.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤由对方召唤·特殊召唤，且其属性与自己墓地中任意怪兽属性相同的怪兽
function c69522668.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
		-- 检查自己墓地是否存在与该怪兽相同属性的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
-- 检查对方召唤·特殊召唤的怪兽中是否存在满足条件的怪兽
function c69522668.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c69522668.cfilter,1,nil,tp)
end
-- 破坏效果的靶子函数，筛选出满足条件的怪兽并设为效果处理对象，设置破坏的操作信息
function c69522668.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c69522668.cfilter,nil,tp)
	-- 将需要破坏的怪兽群设置为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数，将仍存在于场上的对象怪兽破坏
function c69522668.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设为对象的卡片，并过滤出其中仍与效果关联的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
