--相剣大邪－七星龍淵
-- 效果：
-- 调整＋调整以外的幻龙族怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在怪兽区域存在的状态，自己把幻龙族同调怪兽同调召唤的场合才能发动。自己抽1张。
-- ②：对方把怪兽特殊召唤的场合才能发动。那之内的1只除外，给与对方1200伤害。
-- ③：对方把魔法·陷阱卡的效果发动时才能发动。那张卡除外，给与对方1200伤害。
function c47710198.initial_effect(c)
	-- 设置同调召唤手续：调整（不限种族）＋调整以外的幻龙族怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WYRM),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡在怪兽区域存在的状态，自己把幻龙族同调怪兽同调召唤的场合才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47710198,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,47710198)
	e1:SetCondition(c47710198.drcon)
	e1:SetTarget(c47710198.drtg)
	e1:SetOperation(c47710198.drop)
	c:RegisterEffect(e1)
	-- 为这张卡注册一个合并的延迟事件，将特殊召唤成功事件合并为自定义事件，防止②效果在同一连锁中因多只怪兽同时特殊召唤而多次触发；返回该自定义事件代码供e2使用。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,47710198,EVENT_SPSUMMON_SUCCESS)
	-- ②：对方把怪兽特殊召唤的场合才能发动。那之内的1只除外，给与对方1200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47710198,1))  --"特殊召唤的怪兽除外"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(custom_code)
	e2:SetCountLimit(1,47710199)
	e2:SetTarget(c47710198.remtg1)
	e2:SetOperation(c47710198.remop1)
	c:RegisterEffect(e2)
	-- ③：对方把魔法·陷阱卡的效果发动时才能发动。那张卡除外，给与对方1200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47710198,2))  --"发动的卡除外"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,47710200)
	e3:SetCondition(c47710198.remcon2)
	e3:SetTarget(c47710198.remtg2)
	e3:SetOperation(c47710198.remop2)
	c:RegisterEffect(e3)
end
-- ①效果发动条件判定：本次特殊召唤的怪兽只有1只、不是本卡自身、是同调召唤、召唤玩家为自己、且种族为幻龙族。
function c47710198.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc~=e:GetHandler() and tc:IsSummonType(SUMMON_TYPE_SYNCHRO) and tc:IsSummonPlayer(tp)
		and tc:IsRace(RACE_WYRM)
end
-- ①效果的发动目标设定：检查自己能否抽卡；若能，则将当前连锁的目标玩家设为自己、目标参数设为抽卡数量1，并预宣告抽卡操作。
function c47710198.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检测：自己能否因效果抽1张卡，若不能则不能发动①效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的效果对象玩家设置为自己（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果对象参数设置为1（表示抽卡张数）。
	Duel.SetTargetParam(1)
	-- 预宣告本次连锁将进行抽卡操作：类别为抽卡，目标玩家为自己，数量1，具体卡未定，供其他卡的效果响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理时，从当前连锁信息中获取目标玩家和抽卡数量，执行抽卡。
function c47710198.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中保存的目标玩家p和参数d（抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 筛选②效果可除外的怪兽：该怪兽由对方特殊召唤、位于怪兽区、可以除外，并且若传入效果e则还需与该效果有关联（未被效果处理中途脱离）。
function c47710198.filter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsAbleToRemove()
		and (not e or c:IsRelateToEffect(e))
end
-- ②效果的发动目标设定：检查对方本次特殊召唤的怪兽中是否有可除外的怪兽；若有，则将这些候选怪兽全部设为当前连锁的关联卡，并预宣告除外其中1张及造成1200伤害。
function c47710198.remtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c47710198.filter,1,nil,nil,tp) end
	local g=eg:Filter(c47710198.filter,nil,nil,tp)
	-- 将候选怪兽组g设置为当前连锁的关联卡，使这些卡与效果建立联系（用于处理时确认是否仍可除外）。
	Duel.SetTargetCard(g)
	-- 预宣告除外操作：目标组为g，预计除外数量1，目标持有者/位置未知（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 预宣告伤害操作：给与对方玩家1200点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- ②效果处理时，从候选怪兽中过滤仍符合条件的怪兽；若多于1只则选择其中1只除外；成功除外后（或除外的为衍生物时）给与对方1200伤害。
function c47710198.remop1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c47710198.filter,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 向操控者显示选择提示“请选择要除外的卡”，用于选择要除外的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	-- 执行除外操作，若除外成功且该卡在除外区（或因为是衍生物已消失视为除外成功），则后续给予伤害；衍生物不进入除外区，故需要额外判断类型。
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and (tc:IsLocation(LOCATION_REMOVED) or tc:IsType(TYPE_TOKEN)) then
		-- 给对方玩家造成1200点效果伤害。
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end
-- ③效果的发动条件：当前连锁的发动玩家是对方，且对方发动的卡是魔法·陷阱卡，并且那张卡仍然与连锁效果相关（没有被无效离场等）。
function c47710198.remcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果的发动目标设定：确认对方发动的那张魔法·陷阱卡可以除外，并预宣告除外该卡及造成1200伤害。
function c47710198.remtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	-- 预宣告除外操作：目标为连锁中的那张魔法·陷阱卡（eg），数量1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	-- 预宣告伤害操作：给与对方玩家1200点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- ③效果处理时，取得对方发动的那张魔法·陷阱卡；若其仍与效果关联，则将其除外，成功除外后给与对方1200伤害。
function c47710198.remop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if tc:IsRelateToEffect(re) then
		-- 执行除外操作，并确认除外成功且该卡进入除外区（魔法陷阱卡不存在衍生物情况，故只需检查位置）。
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
			-- 给对方玩家造成1200点效果伤害。
			Duel.Damage(1-tp,1200,REASON_EFFECT)
		end
	end
end
