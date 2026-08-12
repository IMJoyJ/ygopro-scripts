--呪眼の眷属 バジリコック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，这张卡在手卡·墓地存在，自己场上有「咒眼」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：对方回合才能发动。用自己场上的怪兽为连接素材把1只「咒眼」连接怪兽连接召唤。那个时候，可以让自己场上的「咒眼」装备魔法卡作为「咒眼」怪兽来成为连接素材。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的两个效果：①手卡·墓地自身特殊召唤，②对方回合用场上怪兽及咒眼装备魔法进行连接召唤。
function s.initial_effect(c)
	-- ①：自己·对方回合，这张卡在手卡·墓地存在，自己场上有「咒眼」怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合才能发动。用自己场上的怪兽为连接素材把1只「咒眼」连接怪兽连接召唤。那个时候，可以让自己场上的「咒眼」装备魔法卡作为「咒眼」怪兽来成为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.lkcon)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「咒眼」怪兽。
function s.spcfilter(c)
	return c:IsSetCard(0x129) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上存在「咒眼」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「咒眼」怪兽。
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查怪兽区域是否有空位，且自身是否可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁运营信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身特殊召唤，并添加离场时除外的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于原本位置，则将其特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- 注册临时效果：允许将自己场上的「咒眼」装备魔法卡作为「咒眼」怪兽成为连接素材。
function s.regop(e,tp)
	-- 那个时候，可以让自己场上的「咒眼」装备魔法卡作为「咒眼」怪兽来成为连接素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.mattg)
	e1:SetValue(s.matval)
	-- 在全局环境中注册该临时连接素材效果。
	Duel.RegisterEffect(e1,tp)
	return e1
end
-- 过滤条件：自己魔陷区表侧表示的「咒眼」装备魔法卡。
function s.mattg(e,c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL)
end
-- 限制该装备魔法只能作为自己连接召唤「咒眼」连接怪兽时的素材。
function s.matval(e,lc,mg,c,tp)
	if not (lc:IsSetCard(0x129) and e:GetHandlerPlayer()==tp) then return false,nil end
	return true,true
end
-- 效果②的发动条件：对方回合。
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：可以进行连接召唤的「咒眼」连接怪兽。
function s.lkfilter(c)
	return c:IsSetCard(0x129) and c:IsLinkSummonable(nil)
end
-- 效果②的发动准备：临时注册装备魔法作为素材的效果，并检查额外卡组是否存在可连接召唤的「咒眼」怪兽。
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local e1=s.regop(e,tp)
		-- 检查额外卡组是否存在可以进行连接召唤的「咒眼」连接怪兽。
		local res=Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil)
		e1:Reset()
		return res
	end
	-- 设置连锁运营信息：从额外卡组特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的处理：注册装备魔法作为素材的效果，选择并进行「咒眼」连接怪兽的连接召唤，随后重置临时效果。
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=s.regop(e,tp)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只可以进行连接召唤的「咒眼」连接怪兽。
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 用自己场上的怪兽为连接素材把1只「咒眼」连接怪兽连接召唤。那个时候，可以让自己场上的「咒眼」装备魔法卡作为「咒眼」怪兽来成为连接素材。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SPSUMMON_COST)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.resetop)
		tc:RegisterEffect(e2)
		-- 进行连接召唤。
		Duel.LinkSummon(tp,tc,nil)
	else
		e1:Reset()
	end
end
-- 连接召唤成功或取消时，重置并清除临时注册的连接素材效果。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	e1:Reset()
	e:Reset()
end
