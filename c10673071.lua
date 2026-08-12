--人工神霊ヴィラカム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己的场上或墓地有「阿莱斯特」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。把1张「召唤魔术」或者有那个卡名记述的魔法卡从卡组到自己场上盖放。
-- ③：对方连锁自己的融合怪兽的效果的发动把卡的效果发动时才能发动。场上的这张卡除外，那个对方的效果无效并除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册3个效果与记录记载卡号的关系
function s.initial_effect(c)
	-- 在卡片中记录关联卡片「召唤魔术」（卡号74063034）
	aux.AddCodeList(c,74063034)
	-- ①：自己的场上或墓地有「阿莱斯特」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。把1张「召唤魔术」或者有那个卡名记述的魔法卡从卡组到自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放效果"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：对方连锁自己的融合怪兽的效果的发动把卡的效果发动时才能发动。场上的这张卡除外，那个对方的效果无效并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示且卡牌名属于「阿莱斯特」的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1e1) and c:IsType(TYPE_MONSTER)
end
-- 效果①的发动条件：自己场上或墓地存在「阿莱斯特」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场上或墓地是否存在至少1张表侧表示的「阿莱斯特」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 效果①的发动目标（检查主要怪兽区是否有空位以及自身是否可以特召）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在进行合法性检测时，确认自己场上是否有可用于特殊召唤怪兽的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（特殊召唤手牌中的此卡）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 以表侧表示特殊召唤自身
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡名为「召唤魔术」或文本中记述了该卡名的魔法卡，且可以在场上盖放
function s.setfilter(c)
	-- 检查卡片是否是「召唤魔术」或记载了其卡名的魔法卡，且可以盖放在场上
	return (c:IsCode(74063034) or aux.IsCodeListed(c,74063034) and c:IsType(TYPE_SPELL)) and c:IsSSetable()
end
-- 效果②的发动目标（检查卡组是否存在满足条件的卡片）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在进行合法性检测时，确认自己卡组中是否存在可盖放的「召唤魔术」或记述了其卡名的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的效果处理（从卡组选择一张卡并盖放到场上）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张需要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将所选的卡片盖放到自己的魔法与陷阱区
		Duel.SSet(tp,tc)
	end
end
-- 效果③的发动条件判断（对方连锁我方融合怪兽的效果发动效果）
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前效果是否可以被无效，以及是否满足“无效并除外”的通用基本条件
	if not Duel.IsChainDisablable(ev) or not aux.nbcon(tp,re) then return false end
	-- 获取被连锁的我方融合怪兽的效果以及发动玩家的信息
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:IsActiveType(TYPE_FUSION) and p==tp and rp==1-tp
end
-- 效果③的发动目标与连锁处理信息设置
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置连锁处理信息：无效对方发动的卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		local g=eg:Clone()
		g:AddCard(e:GetHandler())
		-- 设置连锁处理信息：将自身以及对方发动的卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
	else
		-- 设置连锁处理信息：仅将自身除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
-- 效果③的效果处理（场上的这张卡除外，那个对方的效果无效并除外）
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身是否与连锁关联，并将自身以表侧表示除外
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0
		-- 使对方发动的效果无效，并确认对方卡片依然与该连锁关联
		and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将对方发动的卡片以表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
