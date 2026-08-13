--クリストロン・インパクト
-- 效果：
-- ①：以除外的1只自己的「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤，对方场上有表侧表示怪兽存在的场合，那些对方怪兽的守备力变成0。
-- ②：自己场上的「水晶机巧」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效。这个效果在这张卡送去墓地的回合不能发动。
function c99274184.initial_effect(c)
	-- ①：以除外的1只自己的「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤，对方场上有表侧表示怪兽存在的场合，那些对方怪兽的守备力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99274184.target)
	e1:SetOperation(c99274184.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「水晶机巧」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99274184,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c99274184.discon)
	-- 设置②效果发动时的额外代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c99274184.distg)
	e2:SetOperation(c99274184.disop)
	c:RegisterEffect(e2)
end
-- 定义①效果的取对象筛选条件：对象必须是自己除外区的表侧表示「水晶机巧」怪兽，且能够被特殊召唤。
function c99274184.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xea) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动判定与取对象：先确认主要怪兽区有空位，且除外区存在满足条件的「水晶机巧」怪兽；若正在检查已选对象，则确认该对象是自己除外区中满足条件的怪兽。
function c99274184.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c99274184.filter(chkc,e,tp) end
	-- 在效果发动合法性检查阶段，确认自己主要怪兽区有空位，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动合法性检查阶段，确认除外区存在至少1只满足条件的「水晶机巧」怪兽可以作为对象。
		and Duel.IsExistingTarget(c99274184.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家显示选择提示消息，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由玩家从自己除外区选择1只满足条件的「水晶机巧」怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c99274184.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置当前连锁的处理信息，声明本效果将进行特殊召唤，目标为所选的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽表侧表示特殊召唤到自己场上；若特殊召唤成功且对方场上有表侧表示怪兽，则将这些对方怪兽的守备力变成0。
function c99274184.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然与该效果相关，并将其以表侧表示特殊召唤到自己场上；只有特殊召唤成功时才继续处理后续守备力变化。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方场上所有表侧表示怪兽的集合，用于后续将守备力变成0。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			local sc=g:GetFirst()
			while sc do
				-- 那些对方怪兽的守备力变成0。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
				e1:SetValue(0)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				sc=g:GetNext()
			end
		end
	end
end
-- 定义②效果发动条件的筛选函数：判断一张卡是否为自己场上的表侧表示「水晶机巧」怪兽。
function c99274184.tgfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0xea)
end
-- ②效果的发动条件：当前连锁的效果必须为取对象效果，且其对象中包含自己场上的表侧表示「水晶机巧」怪兽；该效果可以被无效；同时本卡不是被送去墓地的回合内发动。
function c99274184.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁效果所选择的对象卡组，用于检查是否包含自己的「水晶机巧」怪兽。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 综合判定②效果是否满足发动条件：对象组中存在自己场上的表侧表示「水晶机巧」怪兽、当前效果可被无效，并且不在本卡送去墓地的回合内。
	return tg and tg:IsExists(c99274184.tgfilter,1,nil,tp) and Duel.IsChainDisablable(ev) and aux.exccon(e)
end
-- ②效果发动时无需再选择对象，只要发动条件满足即可；同时登记操作信息，表示将对连锁中的效果进行无效。
function c99274184.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的处理信息，声明将对连锁中的那个效果进行无效处理。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：直接无效被连锁的那个效果的发动。
function c99274184.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 令连锁编号为ev的效果无效化，即把那个效果的处理结果变为无效。
	Duel.NegateEffect(ev)
end
