--Chanbar, the Flashy Sportsknight
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 对方场上的怪兽的攻击力下降自己场上的装备魔法卡的数量×400。
-- 「灿荣之运动骑士 钱巴尔」的以下效果1回合各能使用1次。
-- 可以以场上1张其他卡为对象；从自己的手卡·卡组把1张装备魔法卡送去墓地，作为对象的卡破坏。
-- 这张卡在自己墓地存在的场合：可以以自己魔法与陷阱区域的2张表侧表示卡为对象；那些卡破坏，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤条件并启用复活限制
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果1：对方场上的怪兽攻击力下降自己场上装备魔法卡数量×400
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 效果2：以场上1张其他卡为对象；从手卡·卡组把1张装备魔法卡送去墓地，作为对象的卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- 效果3：在自己墓地存在时，以自己魔法与陷阱区域2张表侧表示卡为对象；那些卡破坏，这张卡特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤器函数，用于判断是否为场上表侧表示的装备魔法卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsAllTypes(TYPE_EQUIP+TYPE_SPELL)
end
-- 计算攻击力下降值，返回场上装备魔法卡数量×-400
function s.atkval(e)
	-- 返回场上装备魔法卡数量乘以-400作为攻击力下降值
	return Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-400
end
-- 过滤器函数，用于判断是否为可送去墓地的装备魔法卡
function s.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
-- 效果2的发动条件判断，检查是否有场上的卡可破坏且手卡或卡组有装备魔法卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查是否有场上的卡可作为对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 检查手卡或卡组是否有装备魔法卡
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息，指定要破坏的卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，指定要送去墓地的卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果2的处理函数，执行破坏和送墓操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡或卡组选择1张装备魔法卡送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	local gc=g:GetFirst()
	-- 判断所选装备魔法卡是否成功送去墓地且在墓地
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE)
		and tc:IsRelateToChain() then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤器函数，用于判断是否为场上表侧表示的魔法与陷阱区域的卡
function s.desfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 效果3的发动条件判断，检查是否有足够的召唤位置和可破坏的魔法陷阱卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有2张魔法陷阱区域的卡可破坏
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_SZONE,0,2,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择2张魔法陷阱区域的卡作为对象
	local sg=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,0,2,2,nil)
	-- 设置操作信息，指定要破坏的卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
	-- 设置操作信息，指定特殊召唤的卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果3的处理函数，执行破坏和特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组并筛选出与连锁相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil)
	-- 破坏目标卡组中的卡
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		-- 判断该卡是否与连锁相关且未受王家长眠之谷影响
		if not c:IsRelateToChain() or not aux.NecroValleyFilter()(c) then return end
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
