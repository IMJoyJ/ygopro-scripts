--原質の炉心貫通
-- 效果：
-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把6张卡翻开，用喜欢的顺序回到卡组上面。
-- ②：1回合1次，支付1500基本分才能发动。把1只「原质炉」超量怪兽在自己场上1只3星通常怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ③：超量怪兽超量召唤的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
local s,id,o=GetID()
-- 定义卡片效果初始化函数，注册卡片发动、起动效果和诱发效果
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
-- 卡片发动（效果①）的靶向与发动条件检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的卡片数量是否大于5张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 end
end
-- 卡片发动（效果①）的效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己卡组最上方的6张卡
	Duel.ConfirmDecktop(tp,6)
	-- 获取自己卡组最上方的6张卡
	local g=Duel.GetDecktopGroup(tp,6)
	if g:GetCount()>0 then
		-- 让玩家对卡组最上方的6张卡进行排序
		Duel.SortDecktop(tp,tp,g:GetCount())
	end
end
-- 效果②的发动代价（Cost）处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 过滤条件1：自己场上表侧表示的3星通常怪兽，且存在可重叠召唤的额外卡组怪兽并满足素材限制
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsLevel(3) and c:IsAllTypes(TYPE_NORMAL+TYPE_MONSTER)
		-- 检查额外卡组是否存在满足重叠召唤条件的「原质炉」超量怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查该怪兽是否满足必须作为超量素材的限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤条件2：额外卡组的「原质炉」超量怪兽，且能以指定的怪兽为素材进行超量召唤
function s.filter2(c,e,tp,mc)
	return c:IsSetCard(0x160) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该超量怪兽是否能特殊召唤，且额外卡组特殊召唤区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的靶向与发动条件检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在满足条件的3星通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤的操作信息，准备从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择作为重叠素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的3星通常怪兽
	local mg=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #mg>0 then
		local mc=mg:GetFirst()
		-- 提示玩家选择要特殊召唤的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的「原质炉」超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc)
		local sc=g:GetFirst()
		if sc then
			local og=mc:GetOverlayGroup()
			if og:GetCount()~=0 then
				-- 将原怪兽持有的超量素材转移到新召唤的超量怪兽下
				Duel.Overlay(sc,og)
			end
			sc:SetMaterial(Group.FromCards(mc))
			-- 将作为素材的3星通常怪兽重叠在特殊召唤的超量怪兽下方作为超量素材
			Duel.Overlay(sc,Group.FromCards(mc))
			-- 将该超量怪兽当作超量召唤特殊召唤到场上
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
	-- 这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。③：超量怪兽超量召唤的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤超量怪兽以外怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：不能特殊召唤非超量怪兽（从额外卡组）
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：表侧表示且是通过超量召唤特殊召唤的超量怪兽
function s.ocfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
end
-- 效果③的发动条件：检查是否有超量怪兽超量召唤成功
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ocfilter,1,nil)
end
-- 过滤条件：自己场上表侧表示的「原质炉」超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x160)
end
-- 效果③的靶向与发动条件检测函数
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的「原质炉」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己卡组是否有卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果③的效果处理函数
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上面的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	if Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil) and g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 使接下来的操作不触发卡组洗牌检测
		Duel.DisableShuffleCheck()
		if tc:IsCanOverlay() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sg=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 为选择的怪兽显示靶向动画效果
			Duel.HintSelection(sg)
			-- 将卡组最上面的卡作为超量素材叠放在选择的怪兽下方
			Duel.Overlay(sg:GetFirst(),Group.FromCards(tc))
		else
			-- 若无法作为素材叠放，则将该卡因规则送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
