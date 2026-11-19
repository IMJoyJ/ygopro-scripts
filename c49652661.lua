--武器庫整理
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把最多2张装备魔法卡送去墓地（同名卡最多1张）。
-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。把最多2张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备（同名卡最多1张）。只要这个效果把装备魔法卡装备中，那只怪兽给与对方的战斗伤害变成一半。
local s,id,o=GetID()
-- 初始化卡片效果，分别注册从卡组堆墓最多2张装备魔法卡的①效果和除外墓地自身从手卡·墓地给场上怪兽装备最多2张装备魔法卡的②效果，两者共享1回合1次使用限制
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从卡组把最多2张装备魔法卡送去墓地（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。把最多2张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动代价，使用通用函数把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可送去墓地的卡片：属于装备卡（装备魔法卡）且能够送去墓地
function s.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
-- ①效果的发动检查与信息设置：确认卡组存在可送去墓地的装备魔法卡，并登记从卡组送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁包含从自己卡组将卡片送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果处理：从自己卡组选出1~2张卡名各不相同的装备魔法卡并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中全部可送去墓地的装备魔法卡卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		-- 向发动玩家发送选择要送去墓地的卡片提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让发动玩家从卡组中选出1至2张卡名互不相同的装备魔法卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		-- 将选出的装备魔法卡以效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤可装备给目标怪兽的装备魔法卡：为装备魔法卡、目标怪兽符合其装备对象要求、未受禁止效果影响且满足唯一性限制
function s.eqfilter(c,tc,tp)
	return c:IsAllTypes(TYPE_EQUIP+TYPE_SPELL) and c:CheckEquipTarget(tc) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤可作为②效果对象的场上怪兽：须为表侧表示且自己手卡·墓地中存在至少1张其可装备的装备魔法卡
function s.mfilter(c,tp)
	-- 检查怪兽是否为表侧表示，以及控制者的手卡或墓地中是否存在至少1张满足条件的装备魔法卡可装备给它
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,c:GetControler(),LOCATION_GRAVE+LOCATION_HAND,0,1,nil,c,tp)
end
-- ②效果的发动检查与取对象处理：确认自己场上存在合法对象怪兽且魔陷区仍有空位，让玩家选择1只表侧表示怪兽作为对象并登记从手卡·墓地进行装备的操作信息
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.mfilter(chkc,tp) end
	-- 检查自己怪兽区是否存在可成为对象的表侧表示怪兽，且魔法与陷阱区域仍有至少1个可用空格
	if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 向发动玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从自己怪兽区选择1只符合条件的表侧表示怪兽作为本次连锁的对象
	local g=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 登记本次连锁包含从自己手卡·墓地进行装备的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 执行②效果处理：根据魔陷区剩余格位（最多2个）从手卡·墓地选出卡名各不相同的可装备装备魔法卡装备给对象怪兽，并为每张装备卡附加“装备怪兽给与对方的战斗伤害变成一半”的客户端提示效果，最后统一完成装备流程
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的场上对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己魔法与陷阱区域当前可用的空余格子数
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ct>2 then ct=2 end
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and ct>0 then
		-- 获取自己手卡·墓地中不受王家长眠之谷限制且可装备给目标怪兽的全部装备魔法卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,tc,tp)
		-- 让发动玩家从候选卡片中选出1至最大可装备数量（上限2）且卡名互不相同的装备魔法卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		if not sg or sg:GetCount()==0 then return end
		-- 遍历所选出的每一张准备装备的装备魔法卡
		for ec in aux.Next(sg) do
			-- 以分解步骤将当前装备魔法卡表侧表示装备到目标怪兽上，并判断是否装备成功
			if Duel.Equip(tp,ec,tc,true,true) then
				-- 只要这个效果把装备魔法卡装备中，那只怪兽给与对方的战斗伤害变成一半。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_EQUIP)
				e1:SetDescription(aux.Stringid(id,2))  --"装备怪兽战斗伤害变成一半"
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
				-- 设置战斗伤害变更值，使对方受到的来自装备怪兽的战斗伤害减半
				e1:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1,true)
			end
		end
		-- 结束分解装备过程并统一触发装备相关时点
		Duel.EquipComplete()
	end
end
