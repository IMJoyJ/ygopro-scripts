--真血公ヴァンパイア
-- 效果：
-- 8星怪兽×2只以上
-- 把原本持有者是对方的怪兽作为这张卡的超量召唤的素材的场合，那些等级当作8星使用。这个卡名的②的效果1回合只能使用1次。
-- ①：双方不能把场上的这张卡作为从墓地以外特殊召唤的怪兽的效果的对象。
-- ②：把这张卡1个超量素材取除才能发动。从双方卡组上面把4张卡送去墓地。这个效果让怪兽被送去墓地的场合，再让自己可以把那之内的1只在自己场上特殊召唤。
function c73082255.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置超量召唤手续：需要2只以上的8星怪兽
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	-- 把原本持有者是对方的怪兽作为这张卡的超量召唤的素材的场合，那些等级当作8星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c73082255.lvtg)
	e1:SetValue(c73082255.lvval)
	c:RegisterEffect(e1)
	-- ①：双方不能把场上的这张卡作为从墓地以外特殊召唤的怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c73082255.eval)
	c:RegisterEffect(e2)
	-- ②：把这张卡1个超量素材取除才能发动。从双方卡组上面把4张卡送去墓地。这个效果让怪兽被送去墓地的场合，再让自己可以把那之内的1只在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73082255,0))
	e3:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,73082255)
	e3:SetCost(c73082255.discost)
	e3:SetTarget(c73082255.distg)
	e3:SetOperation(c73082255.disop)
	c:RegisterEffect(e3)
end
-- 过滤等级在1以上且原本持有者为对方的怪兽
function c73082255.lvtg(e,c)
	return c:IsLevelAbove(1) and c:GetOwner()~=e:GetHandlerPlayer()
end
-- 若作为本卡的超量素材，则该怪兽的等级当作8星使用
function c73082255.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 8
	else return lv end
end
-- 过滤从墓地以外特殊召唤的怪兽在场上发动的效果
function c73082255.eval(e,re,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE and rc:IsSummonType(SUMMON_TYPE_SPECIAL)
		and (not rc:IsSummonLocation(LOCATION_GRAVE) or (rc:GetOriginalType()&TYPE_TRAP~=0))
end
-- 效果②的代价：取除这张卡的1个超量素材
function c73082255.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动准备：确认双方卡组是否能送去墓地，并设置操作信息
function c73082255.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否都能从卡组上面把4张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,4) and Duel.IsPlayerCanDiscardDeck(1-tp,4) end
	-- 设置操作信息：包含从双方卡组送去墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,4)
end
-- 过滤在墓地且可以被特殊召唤的怪兽
function c73082255.cfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的效果处理：将双方卡组顶的4张卡送去墓地，若有怪兽被送去墓地，则可选择其中1只在自己场上特殊召唤
function c73082255.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上方的4张卡送去墓地
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
	-- 获取自己因效果送去墓地的卡片组
	local g=Duel.GetOperatedGroup()
	-- 将对方卡组最上方的4张卡送去墓地
	Duel.DiscardDeck(1-tp,4,REASON_EFFECT)
	-- 获取对方因效果送去墓地的卡片组
	local g2=Duel.GetOperatedGroup()
	g:Merge(g2)
	-- 筛选出送去墓地的卡片中，不受王家长眠之谷影响且可以特殊召唤的怪兽
	local fg=g:Filter(aux.NecroValleyFilter(c73082255.cfilter),nil,e,tp)
	-- 若有可特殊召唤的怪兽、自己场上有空位，且玩家选择进行特殊召唤
	if fg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(73082255,1)) then  --"是否选被送去墓地的怪兽特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤不与送去墓地同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=fg:Select(tp,1,1,nil)
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
