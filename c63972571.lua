--獣神王バルバロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把等级合计直到8以上的自己场上的怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：从自己墓地以及自己场上的表侧表示怪兽之中把1只「巴巴罗斯」怪兽除外，以对方场上2张卡为对象才能发动。那些卡破坏。
-- ③：这张卡可以向对方怪兽全部各作1次攻击。
function c63972571.initial_effect(c)
	-- ①：把等级合计直到8以上的自己场上的怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63972571,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63972571)
	e1:SetCost(c63972571.spcost)
	e1:SetTarget(c63972571.sptg)
	e1:SetOperation(c63972571.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地以及自己场上的表侧表示怪兽之中把1只「巴巴罗斯」怪兽除外，以对方场上2张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63972571,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,63972572)
	e2:SetCost(c63972571.descost)
	e2:SetTarget(c63972571.destg)
	e2:SetOperation(c63972571.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡可以向对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤可解放的怪兽：等级在1以上，且为自己场上的怪兽或场上表侧表示的怪兽
function c63972571.rfilter(c,tp)
	return c:IsLevelAbove(1) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查选中的怪兽组是否满足等级合计在8以上，且解放后主怪兽区有空位
function c63972571.fselect(g,tp)
	-- 设置已选择的卡片组，用于后续的等级合计判定
	Duel.SetSelectedCard(g)
	-- 检查选中的怪兽等级合计是否在8以上，且解放这些怪兽后主怪兽区是否有足够的空位
	return g:CheckWithSumGreater(Card.GetLevel,8) and aux.mzctcheckrel(g,tp)
end
-- 特殊召唤效果的发动代价：解放等级合计8以上的自己场上的怪兽
function c63972571.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可解放且满足过滤条件的怪兽组
	local g=Duel.GetReleaseGroup(tp):Filter(c63972571.rfilter,nil,tp)
	if chk==0 then return g:CheckSubGroup(c63972571.fselect,1,g:GetCount(),tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroup(tp,c63972571.fselect,false,1,g:GetCount(),tp)
	-- 强制使用代替解放效果的次数（如暗影敌托邦等效果）
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(rg,REASON_COST)
end
-- 特殊召唤效果的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c63972571.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含1张自身卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身从手卡特殊召唤
function c63972571.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤可作为代价除外的卡：自己场上表侧表示或墓地的「巴巴罗斯」怪兽
function c63972571.cfilter(c)
	return c:IsSetCard(0x13e) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and c:IsAbleToRemoveAsCost()
end
-- 破坏效果的发动代价：从自己场上或墓地除外1只「巴巴罗斯」怪兽
function c63972571.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上或墓地是否存在至少1张满足除外条件的「巴巴罗斯」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63972571.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张自己场上或墓地满足条件的「巴巴罗斯」怪兽
	local g=Duel.SelectMatchingCard(tp,c63972571.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽以表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 破坏效果的发动准备：选择对方场上2张卡作为对象，并设置破坏的操作信息
function c63972571.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少2张可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TURE,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上2张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TURE,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 设置破坏的操作信息，包含选中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 破坏效果的处理：破坏作为对象的卡
function c63972571.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 破坏所有仍与效果相关的对象卡片
	Duel.Destroy(tg,REASON_EFFECT)
end
