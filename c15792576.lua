--天魔神 シドヘルズ
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡上级召唤成功的场合才能发动。为这张卡的上级召唤而解放的怪兽的种族·属性的以下效果适用。
-- ●天使族·光属性：从卡组把1只天使族·光属性或者恶魔族·暗属性的怪兽加入手卡。
-- ●恶魔族·暗属性：从卡组把天使族·光属性和恶魔族·暗属性的怪兽各最多1只送去墓地。
function c15792576.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：这张卡上级召唤成功的场合才能发动。为这张卡的上级召唤而解放的怪兽的种族·属性的以下效果适用。●天使族·光属性：从卡组把1只天使族·光属性或者恶魔族·暗属性的怪兽加入手卡。●恶魔族·暗属性：从卡组把天使族·光属性和恶魔族·暗属性的怪兽各最多1只送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15792576,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c15792576.opcon)
	e1:SetTarget(c15792576.optg)
	e1:SetOperation(c15792576.opop)
	c:RegisterEffect(e1)
	-- 为这张卡的上级召唤而解放的怪兽的种族·属性
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c15792576.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查怪兽是否同时满足指定的种族和属性，作为筛选解放素材或检索/送墓对象的通用判定函数。
function c15792576.chkfilter(c,rac,att)
	return c:IsRace(rac) and c:IsAttribute(att)
end
-- 在上级召唤成功时检查实际解放的素材，若包含天使族·光属性则标记+1，包含恶魔族·暗属性则标记+2，并将结果存入效果e1的Label，供后续分支判断。
function c15792576.valcheck(e,c)
	local label=0
	local g=c:GetMaterial()
	if g:IsExists(c15792576.chkfilter,1,nil,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		label=label+1
	end
	if g:IsExists(c15792576.chkfilter,1,nil,RACE_FIEND,ATTRIBUTE_DARK) then
		label=label+2
	end
	e:GetLabelObject():SetLabel(label)
end
-- 发动条件判定：这张卡以“上级召唤”方式成功召唤，且素材标记大于0（即解放了符合条件的怪兽）时才能发动效果。
function c15792576.opcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()>0
end
-- 筛选卡组中“天使族·光属性或恶魔族·暗属性”且能够加入手卡的怪兽（注意原代码因缺少括号，实际仅对恶魔族·暗属性分支调用了IsAbleToHand）。
function c15792576.thfilter(c)
	return (c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToHand()
end
-- 筛选卡组中“天使族·光属性或恶魔族·暗属性”且能够送去墓地的怪兽（注意原代码同样存在优先级问题：仅对恶魔族·暗属性分支检查了IsAbleToGrave）。
function c15792576.tgfilter(c)
	return (c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToGrave()
end
-- 效果发动时的目标/合法性判定函数：根据素材标签label决定可选分支。标签1表示只有天使光，要求卡组存在可加入手卡的符合条件的卡；标签2表示只有恶魔暗，要求卡组存在可送墓的符合条件的卡；标签3表示两者都有，直接允许发动。发动时若标签为1则设置“加入手卡”的类别与操作信息，若标签为2则设置“送去墓地”的类别与操作信息；标签3未单独设置。
function c15792576.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabel()
	if chk==0 then
		if label==1 then
			-- 检查卡组中是否存在至少1张满足thfilter（可加入手卡的天使光或恶魔暗怪兽），以此作为标签1对应的发动条件。
			return Duel.IsExistingMatchingCard(c15792576.thfilter,tp,LOCATION_DECK,0,1,nil)
		elseif label==2 then
			-- 检查卡组中是否存在至少1张满足tgfilter（可送去墓地的天使光或恶魔暗怪兽），以此作为标签2对应的发动条件。
			return Duel.IsExistingMatchingCard(c15792576.tgfilter,tp,LOCATION_DECK,0,1,nil)
		else
			return true
		end
	end
	e:SetLabel(label)
	if label==1 then
		-- 向对方玩家提示“对方选择了卡组检索”（即本效果将执行从卡组加入手卡的分支）。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(15792576,1))  --"卡组检索"
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置连锁操作信息：从卡组将1张卡加入手卡（处理时再选择具体卡），供后续效果检测使用。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif label==2 then
		-- 向对方玩家提示“对方选择了送去墓地”（即本效果将执行从卡组送墓的分支）。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(15792576,2))  --"送去墓地"
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 设置连锁操作信息：从卡组将1张卡送去墓地（处理时再选择具体卡），供后续效果检测使用。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理函数：根据素材标签执行对应分支。标签1时从卡组选1张符合条件的怪兽加入手卡并给对方确认；标签2时从卡组选至多2张（由种族互不相同的筛选保证“天使光/恶魔暗各最多1张”）送去墓地；标签3未实现处理。
function c15792576.opop(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	if label==1 then
		-- 弹出选择提示，提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从自己卡组中选择1张满足thfilter的怪兽卡（处理时选择）。
		local g1=Duel.SelectMatchingCard(tp,c15792576.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g1:GetCount()>0 then
			-- 将选中的卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g1)
		end
	elseif label==2 then
		-- 获取卡组中所有满足tgfilter的怪兽卡，作为送墓处理的可选集合。
		local g=Duel.GetMatchingGroup(c15792576.tgfilter,tp,LOCATION_DECK,0,nil)
		-- 弹出选择提示，提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从备选集合中选择1至2张卡，且所选卡的种族互不相同（确保天使族和恶魔族各最多1张），符合原效果“各最多1只”的限制。
		local g2=g:SelectSubGroup(tp,aux.drccheck,false,1,2)
		if g2 then
			-- 将选中的卡以效果原因送去墓地。
			Duel.SendtoGrave(g2,REASON_EFFECT)
		end
	end
end
