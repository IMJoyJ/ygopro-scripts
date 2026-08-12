--予見者ゾルガ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「预见者 卓尔加」以外的天使族·地属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己从自己以及对方的卡组上面各最多5张确认。
-- ②：把这张卡解放作召唤的怪兽的攻击宣言时，把墓地的这张卡除外才能发动。那只怪兽破坏，给与对方2000伤害。
function c31525442.initial_effect(c)
	-- ①：自己场上有「预见者 卓尔加」以外的天使族·地属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己从自己以及对方的卡组上面各最多5张确认。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31525442,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31525442)
	e1:SetCondition(c31525442.spcon)
	e1:SetTarget(c31525442.sptg)
	e1:SetOperation(c31525442.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放作召唤的怪兽的攻击宣言时，把墓地的这张卡除外才能发动。那只怪兽破坏，给与对方2000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31525442,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,31525443)
	e2:SetCondition(c31525442.dmcon)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31525442.dmtg)
	e2:SetOperation(c31525442.dmop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c31525442.regcon)
	e3:SetOperation(c31525442.regop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上存在一张表侧表示的天使族·地属性怪兽且不是卓尔加
function c31525442.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_FAIRY)
		and not c:IsCode(31525442)
end
-- 效果发动条件：自己场上有「预见者 卓尔加」以外的天使族·地属性怪兽存在
function c31525442.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己来看场上是否存在至少1张满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c31525442.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤的处理信息
function c31525442.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：将自己手牌中的卓尔加特殊召唤到场上，并确认自己和对方卡组最上方的卡
function c31525442.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自己手牌中的卓尔加特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使之后的效果视为不同时处理
		Duel.BreakEffect()
		for p=tp,1-tp,1-tp-tp do
			-- 获取玩家p的卡组最上方的所有卡
			local g=Duel.GetFieldGroup(p,LOCATION_DECK,0)
			if #g>0 then
				local ct={}
				for i=5,1,-1 do
					if #g>=i then
						table.insert(ct,i)
					end
				end
				-- 提示玩家选择确认的卡数量
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31525442,(p==tp and 2 or 3)))
				-- 玩家选择确认的卡数量
				local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
				-- 获取玩家p卡组最上方的ac张卡
				local sg=Duel.GetDecktopGroup(p,ac)
				-- 确认玩家tp的卡组最上方的ac张卡
				Duel.ConfirmCards(tp,sg)
			end
		end
	end
end
-- 攻击宣言时的发动条件：攻击怪兽是解放卓尔加作召唤的怪兽
function c31525442.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次攻击的怪兽
	local at=Duel.GetAttacker()
	return at:GetFlagEffectLabel(31525442)==c:GetFieldID()
end
-- 设置伤害效果的处理信息
function c31525442.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取此次攻击的怪兽
	local at=Duel.GetAttacker()
	-- 设置此次效果的目标为攻击怪兽
	Duel.SetTargetCard(at)
	-- 设置此次效果的处理信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
	-- 设置此次效果的处理信息为给与对方2000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 伤害效果处理：破坏目标怪兽并给与对方2000伤害
function c31525442.dmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标怪兽
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方2000伤害
			Duel.Damage(1-tp,2000,REASON_EFFECT)
		end
	end
end
-- 判定是否为因召唤而成为素材
function c31525442.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return r==REASON_SUMMON and rc:IsFaceup()
end
-- 注册flag效果：当因召唤成为素材时，为召唤者注册flag，用于触发效果
function c31525442.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if r==REASON_SUMMON and rc:IsFaceup() and c:IsLocation(LOCATION_GRAVE) then
		rc:RegisterFlagEffect(31525442,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,c:GetFieldID(),aux.Stringid(31525442,4))  --"解放「预见者 卓尔加」作召唤"
	end
end
