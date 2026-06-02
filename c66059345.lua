--原質の炉心貫通
-- 效果：
-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把6张卡翻开，用喜欢的顺序回到卡组上面。
-- ②：1回合1次，支付1500基本分才能发动。把1只「原质炉」超量怪兽在自己场上1只3星通常怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ③：超量怪兽超量召唤的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
local s,id,o=GetID()
-- 初始化效果注册过程，分别注册魔法发动时的排序效果、额外超量怪兽的重叠超量召唤效果、以及超量召唤成功时追加卡组顶牌作为素材的效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把6张卡翻开，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付1500基本分才能发动。把1只「原质炉」超量怪兽在自己场上1只3星通常怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：超量怪兽超量召唤的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"作为超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.ovcon)
	e3:SetTarget(s.ovtg)
	e3:SetOperation(s.ovop)
	c:RegisterEffect(e3)
end
-- 魔法发动时翻开卡组顶牌并排序效果的发动准备与合法性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否有6张以上的卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 end
end
-- 魔法发动时翻开卡组顶牌并排序效果的实际处理过程
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己卡组最上方6张卡片
	Duel.ConfirmDecktop(tp,6)
	-- 获取自己卡组最上方的6张卡片组
	local g=Duel.GetDecktopGroup(tp,6)
	if g:GetCount()>0 then
		-- 让玩家对卡组最上方的6张卡以喜欢的顺序进行重新排序并放回卡组上方
		Duel.SortDecktop(tp,tp,g:GetCount())
	end
end
-- 特殊召唤效果的消耗动作，玩家支付1500基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 玩家支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 过滤自己场上表侧表示的3星通常怪兽，且其能够重叠超量召唤，满足素材限制
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsLevel(3) and c:IsAllTypes(TYPE_NORMAL+TYPE_MONSTER)
		-- 并检查额外卡组是否存在可以该怪兽为素材进行超量召唤的「原质炉」超量怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 且该怪兽必须满足受规则/效果限制作为超量素材的检测
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中的「原质炉」超量怪兽，其可以用指定的怪兽为素材进行超量召唤
function s.filter2(c,e,tp,mc)
	return c:IsSetCard(0x160) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 且该额外怪兽允许超量特殊召唤，同时场上存在可用于从额外卡组召唤的空格
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 特殊召唤效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在符合条件的3星通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向对方玩家提示此效果已被激活发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置在连锁处理时从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的实际处理过程，并将超量怪兽重叠特殊召唤，同时注册此回合额外召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择作为重叠超量素材的目标卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只符合条件的3星通常怪兽
	local mg=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #mg>0 then
		local mc=mg:GetFirst()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只符合条件的「原质炉」超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc)
		local sc=g:GetFirst()
		if sc then
			local og=mc:GetOverlayGroup()
			if og:GetCount()~=0 then
				-- 将原本怪兽身上持有的所有叠放素材转移并叠放到新的超量怪兽下方
				Duel.Overlay(sc,og)
			end
			sc:SetMaterial(Group.FromCards(mc))
			-- 将所选的3星通常怪兽作为超量素材重叠在所选超量怪兽下方
			Duel.Overlay(sc,Group.FromCards(mc))
			-- 将所选的超量怪兽以超量召唤的形式在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
	-- 这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册本回合不能从额外卡组特殊召唤超量怪兽以外的怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤非超量怪兽的额外卡组怪兽，用于限制特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤场上表侧表示进行过超量召唤的超量怪兽
function s.ocfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
end
-- 检查是否有超量怪兽成功进行了超量召唤，作为效果的发动条件
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ocfilter,1,nil)
end
-- 过滤场上表侧表示的「原质炉」超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x160)
end
-- 叠放卡组最上方卡片作为超量素材效果的发动准备与合法性检查
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在符合条件的「原质炉」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且自己卡组数量大于0
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 向对方玩家提示此效果已被激活发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 叠放卡组最上方卡片作为超量素材效果的实际处理过程
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	-- 如果场上存在符合条件的超量怪兽且获取卡组顶牌成功，则继续处理
	if Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil) and g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 禁用下一个操作的卡组洗牌自动检测
		Duel.DisableShuffleCheck()
		if tc:IsCanOverlay() then
			-- 提示玩家选择场上表侧表示的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 玩家选择自己场上1只符合条件的「原质炉」超量怪兽
			local sg=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 手动为所选怪兽显示选定特效
			Duel.HintSelection(sg)
			-- 将自己卡组最上方的卡片作为超量素材叠放在所选的超量怪兽下方
			Duel.Overlay(sg:GetFirst(),Group.FromCards(tc))
		else
			-- 若卡片无法作为素材叠放，则依规则将其送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
