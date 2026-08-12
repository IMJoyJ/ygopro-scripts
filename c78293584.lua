--フィリアス・ディアベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只8星以上的「迪亚贝尔」怪兽加入手卡。只有对方场上才有怪兽存在的场合，也能不加入手卡特殊召唤。
-- ②：这张卡被除外的场合才能发动。自己场上的全部「迪亚贝尔」怪兽的攻击力上升500。
local s,id,o=GetID()
-- 注册卡片效果：①卡组检索或特召「迪亚贝尔」怪兽的效果，②被除外时自己场上「迪亚贝尔」怪兽攻击力上升的效果
function s.initial_effect(c)
	-- ①：从卡组把1只8星以上的「迪亚贝尔」怪兽加入手卡。只有对方场上才有怪兽存在的场合，也能不加入手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。自己场上的全部「迪亚贝尔」怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中8星以上的「迪亚贝尔」怪兽，并判断其是否能加入手卡或在满足条件时特殊召唤
function s.thfilter(c,e,tp,check)
	return c:IsSetCard(0x19b) and c:IsLevelAbove(8) and
		(c:IsAbleToHand()
			or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果①的发动准备与合法性检查，判断卡组中是否存在可检索或特殊召唤的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有可用的怪兽区域，且自己场上没有怪兽
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			-- 检查对方场上是否存在怪兽（用于判断是否满足“只有对方场上才有怪兽存在”的特殊召唤条件）
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足条件的8星以上「迪亚贝尔」怪兽
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 效果①的处理：从卡组选择1只8星以上的「迪亚贝尔」怪兽，根据条件选择加入手卡或特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己场上是否有可用怪兽区域且自己场上没有怪兽
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 再次检查对方场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1只满足条件的8星以上「迪亚贝尔」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	local b=check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 如果该卡可以加入手卡，且不满足特召条件或玩家选择“加入手卡”选项
	if tc:IsAbleToHand() and (not b or Duel.SelectOption(tp,1190,1152)==0) then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	elseif b then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示且不受该效果影响的「迪亚贝尔」怪兽
function s.atkfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x19b) and (not e or not c:IsImmuneToEffect(e))
end
-- 效果②的发动准备，检查自己场上是否存在表侧表示的「迪亚贝尔」怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「迪亚贝尔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的处理：使自己场上全部「迪亚贝尔」怪兽的攻击力上升500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上全部表侧表示的「迪亚贝尔」怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil,e)
	if g:GetCount()>0 then
		-- 遍历获取到的所有「迪亚贝尔」怪兽
		for tc in aux.Next(g) do
			-- 自己场上的全部「迪亚贝尔」怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
