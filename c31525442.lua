--予見者ゾルガ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「预见者 卓尔加」以外的天使族·地属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己从自己以及对方的卡组上面各最多5张确认。
-- ②：把这张卡解放作召唤的怪兽的攻击宣言时，把墓地的这张卡除外才能发动。那只怪兽破坏，给与对方2000伤害。
function c31525442.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「预见者 卓尔加」以外的天使族·地属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己从自己以及对方的卡组上面各最多5张确认。
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
	-- 设置②效果的发动代价：将墓地的这张卡除外作为COST才能发动。aux.bfgcost负责检查可除外性并执行除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31525442.dmtg)
	e2:SetOperation(c31525442.dmop)
	c:RegisterEffect(e2)
	-- 把这张卡解放作召唤的怪兽的攻击宣言时。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c31525442.regcon)
	e3:SetOperation(c31525442.regop)
	c:RegisterEffect(e3)
end
-- cfilter过滤条件：判断为表侧表示、地属性、天使族，且不是「预见者 卓尔加」自身，用于①效果的发动条件。
function c31525442.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_FAIRY)
		and not c:IsCode(31525442)
end
-- ①效果的发动条件（spcon）：检查己方主要怪兽区是否存在满足cfilter的怪兽。
function c31525442.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 执行检查：从己方场上（LOCATION_MZONE）筛选是否存在至少1张满足cfilter的怪兽。
	return Duel.IsExistingMatchingCard(c31525442.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动目标函数（sptg）：判定能否从手卡特殊召唤这张卡；chk==0时只做合法性检查，不进行额外选择。
function c31525442.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查之一：我方主要怪兽区有空位可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记效果处理情报：本次效果将对这张卡进行特殊召唤（1张），使相关卡（如星尘龙等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理（spop）：将手卡的这张卡特殊召唤；若特殊召唤成功，则中断连锁，并分别对自己和对方的卡组，由操作者宣言各最多5张的数量，确认相应卡牌。
function c31525442.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤，若成功（返回值非0）才继续后续确认卡组的处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使用Duel.BreakEffect中断当前效果，使特殊召唤后的确认卡组处理不在同一时点进行，避免错过时点，对应“那之后”的处理。
		Duel.BreakEffect()
		for p=tp,1-tp,1-tp-tp do
			-- 获取玩家p的卡组全部卡片，用于判断可确认的最大张数（最多5张且不超过卡组数量）。
			local g=Duel.GetFieldGroup(p,LOCATION_DECK,0)
			if #g>0 then
				local ct={}
				for i=5,1,-1 do
					if #g>=i then
						table.insert(ct,i)
					end
				end
				-- 显示选择提示，提示操作玩家选择要确认的数量；根据p是否为tp区分是“自己卡组”还是“对方卡组”的提示文案。
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31525442,(p==tp and 2 or 3)))
				-- 让操作玩家tp宣言一个数字（从可选数量1~5中），作为要确认的卡组上方张数。
				local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
				-- 取得玩家p卡组上方的ac张卡，作为将要确认的卡牌集合。
				local sg=Duel.GetDecktopGroup(p,ac)
				-- 将选出的卡牌展示给玩家tp确认。
				Duel.ConfirmCards(tp,sg)
			end
		end
	end
end
-- ②效果的发动条件（dmcon）：攻击宣言的怪兽必须是被标记为解放了这张卡而召唤的怪兽（其flag标记值等于这张卡的field ID）。
function c31525442.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击宣言的怪兽（用于判定是否满足②效果的发动条件）。
	local at=Duel.GetAttacker()
	return at:GetFlagEffectLabel(31525442)==c:GetFieldID()
end
-- ②效果的发动目标函数（dmtg）：将攻击宣言的怪兽设为效果对象，并登记破坏与伤害的操作信息；发动时不需要额外选择。
function c31525442.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前攻击宣言的怪兽（用于设置为效果对象）。
	local at=Duel.GetAttacker()
	-- 将攻击宣言的怪兽设置为当前连锁处理的对象（取对象），确保后续能获得该怪兽。
	Duel.SetTargetCard(at)
	-- 登记破坏操作信息：将对所取对象进行破坏（1张），供全场效果连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
	-- 登记伤害操作信息：将对对方玩家造成2000点伤害。targets为nil表示伤害对象不固定（直到处理时才会给对方）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- ②效果处理（dmop）：取得对象怪兽；若对象仍与效果关联，则将其破坏；破坏成功后给与对方2000伤害。
function c31525442.dmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象（攻击怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该怪兽；若破坏成功（返回值非0）才继续给予伤害。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方玩家（1-tp）2000点效果伤害。
			Duel.Damage(1-tp,2000,REASON_EFFECT)
		end
	end
end
-- e3的触发条件（regcon）：这张卡作为解放素材用于召唤，并且召唤出的怪兽是表侧表示。
function c31525442.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return r==REASON_SUMMON and rc:IsFaceup()
end
-- e3的处理（regop）：在满足条件时，给召唤出的怪兽注册标记，记录它是解放了「预见者 卓尔加」而召唤的，并附加客户端提示文本，供②效果判断使用。
function c31525442.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if r==REASON_SUMMON and rc:IsFaceup() and c:IsLocation(LOCATION_GRAVE) then
		rc:RegisterFlagEffect(31525442,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,c:GetFieldID(),aux.Stringid(31525442,4))  --"解放「预见者 卓尔加」作召唤"
	end
end
