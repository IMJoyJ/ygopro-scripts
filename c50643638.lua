--明滅騎士チャンバル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方场上的怪兽的攻击力下降自己场上的装备魔法卡数量×400。
-- ②：以场上1张其他卡为对象才能发动。从手卡·卡组把1张装备魔法卡送去墓地，作为对象的卡破坏。
-- ③：这张卡在墓地存在的场合，以自己的魔法与陷阱区域2张表侧表示卡为对象才能发动。那些卡破坏，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果：注册同调召唤手续与苏生限制，并依次注册①②③三个效果
function s.initial_effect(c)
	-- 注册同调召唤手续：1只调整＋1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方场上的怪兽的攻击力下降自己场上的装备魔法卡数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：以场上1张其他卡为对象才能发动。从手卡·卡组把1张装备魔法卡送去墓地，作为对象的卡破坏。
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
	-- ③：这张卡在墓地存在的场合，以自己的魔法与陷阱区域2张表侧表示卡为对象才能发动。那些卡破坏，这张卡特殊召唤。
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
-- 过滤函数：筛选自己场上表侧表示的装备魔法卡（用于统计装备魔法卡数量）
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsAllTypes(TYPE_EQUIP+TYPE_SPELL)
end
-- ①效果的攻击力数值计算函数
function s.atkval(e)
	-- 统计自己场上的装备魔法卡数量，返回其数量×400的负数作为对方怪兽的攻击力下降值
	return Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-400
end
-- 过滤函数：筛选可以送去墓地的装备魔法卡
function s.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
-- ②效果的目标函数：取对象与发动条件检查
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 发动条件检查：场上存在1张这张卡以外的可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 发动条件检查：自己的手卡·卡组存在1张可以送去墓地的装备魔法卡
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让自己玩家选择场上1张这张卡以外的卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：这个连锁将破坏作为对象的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：这个连锁将从自己的手卡·卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果的处理：从手卡·卡组把1张装备魔法卡送去墓地，作为对象的卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（要破坏的卡）
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让自己玩家从手卡·卡组选择1张可以送去墓地的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	local gc=g:GetFirst()
	-- 如果选择的装备魔法卡因效果被送去墓地且确实在墓地存在
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE)
		and tc:IsRelateToChain() then
		-- 将作为对象的卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：筛选自己魔法与陷阱区域（序号0-4）的表侧表示卡
function s.desfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- ③效果的目标函数：发动条件检查与取对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：自己的主要怪兽区域有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 发动条件检查：自己的魔法与陷阱区域存在2张可以作为效果对象的表侧表示卡
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_SZONE,0,2,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让自己玩家选择自己魔法与陷阱区域2张表侧表示卡作为效果对象
	local sg=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,0,2,2,nil)
	-- 设置操作信息：这个连锁将破坏作为对象的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
	-- 设置操作信息：这个连锁将把这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的处理：那些卡破坏，这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡中仍与连锁关联的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil)
	-- 如果成功破坏了那些卡
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		-- 如果这张卡不再与连锁关联，或受王家长眠之谷影响，则中断处理
		if not c:IsRelateToChain() or not aux.NecroValleyFilter()(c) then return end
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
