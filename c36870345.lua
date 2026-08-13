--ドラグニティ－アキュリス
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只「龙骑兵团」怪兽特殊召唤，那之后，自己场上的表侧表示的这张卡当作装备卡使用给那只特殊召唤的怪兽装备。
-- ②：给怪兽装备的这张卡被送去墓地的场合，以场上1张卡为对象发动。那张卡破坏。
function c36870345.initial_effect(c)
	-- “①：这张卡召唤成功时才能发动。从手卡把1只「龙骑兵团」怪兽特殊召唤，那之后，自己场上的表侧表示的这张卡当作装备卡使用给那只特殊召唤的怪兽装备。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36870345,0))  --"特殊召唤并装备"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c36870345.sptg)
	e1:SetOperation(c36870345.spop)
	c:RegisterEffect(e1)
	-- “②：给怪兽装备的这张卡被送去墓地的场合，以场上1张卡为对象发动。那张卡破坏。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36870345,1))  --"场上的1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c36870345.descon)
	e2:SetTarget(c36870345.destg)
	e2:SetOperation(c36870345.desop)
	c:RegisterEffect(e2)
end
-- 定义效果①的特殊召唤筛选条件：目标必须是「龙骑兵团」怪兽，且能被当前效果特殊召唤（通过效果e、召唤方式0、由tp玩家特殊召唤，并按正常限制检查）。
function c36870345.filter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判断：检查自己场上是否有主要怪兽区和魔法陷阱区空位，以及手牌是否存在至少1只满足filter条件的「龙骑兵团」怪兽。
function c36870345.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区与魔法陷阱区是否都有可用空位，确保后续特殊召唤和装备动作能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手牌中是否存在至少1只满足c36870345.filter条件的「龙骑兵团」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c36870345.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息登记为：含有特殊召唤分类，预定从手牌特殊召唤1只怪兽，以便其他卡牌效果进行响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 将本次连锁的操作信息登记为：含有装备分类，预定由本卡自身进行装备，以便其他卡牌效果进行响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的处理流程：若怪兽区有空位，则从手牌选择1只符合条件的「龙骑兵团」怪兽表侧表示特殊召唤；之后检查自身是否仍适合装备以及魔陷区是否有空位，为后续的装备处理做准备。
function c36870345.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区空位，则无法特殊召唤，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息，引导进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选取1只满足「龙骑兵团」字段且可被特殊召唤的怪兽作为特殊召唤对象（此处为不取对象的选择）。
	local g=Duel.SelectMatchingCard(tp,c36870345.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽以表侧表示形式特殊召唤到自己的主要怪兽区，召唤方式为效果特殊召唤。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		-- 若自己场上没有空闲的魔法陷阱区，则后续装备处理无法进行，效果处理到此结束。
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 中断当前效果的处理，使特殊召唤成功与后续装备动作不在同一时点连续处理，留出正确的发动时点。
	Duel.BreakEffect()
	-- 将这张卡作为装备卡装备到刚才特殊召唤的怪兽身上；若装备操作失败（如无法装备），则终止后续处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- “自己场上的表侧表示的这张卡当作装备卡使用给那只特殊召唤的怪兽装备。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c36870345.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制判定：只有e:GetLabelObject()记录的怪兽（即特殊召唤的那只怪兽）才允许成为这张装备卡的装备对象。
function c36870345.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 效果②的发动条件：这张卡作为装备卡在魔陷区存在时被送去墓地，且此前确实装备着怪兽，并且送入墓地的原因不是“失去装备对象”（即不是因装备怪兽离场而规则破坏），满足条件才能发动。
function c36870345.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 效果②的目标选择：以场上1张卡为对象发动，选择后把对象登记到连锁，并设置破坏的操作信息。
function c36870345.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 向玩家显示“请选择要破坏的卡”的提示消息，引导选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张卡作为效果对象（取对象），该卡可以是场上任意表侧或里侧的卡。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将破坏操作信息登记为：以所选卡为对象，预定破坏的数量等于选择数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的处理：从连锁中取出对象卡，若该卡仍与本效果有关联，则将其以效果原因破坏。
function c36870345.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动效果时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡片（REASON_EFFECT）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
