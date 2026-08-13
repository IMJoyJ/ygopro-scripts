--機皇神龍トリスケリア
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把「机皇」怪兽3种类各1只除外的场合可以特殊召唤。
-- ①：1回合1次，这张卡的攻击宣言时才能发动。把对方的额外卡组确认，选那之内的1只怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：有同调怪兽装备的这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
function c4837861.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把「机皇」怪兽3种类各1只除外的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c4837861.spcon)
	e2:SetTarget(c4837861.sptg)
	e2:SetOperation(c4837861.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，这张卡的攻击宣言时才能发动。把对方的额外卡组确认，选那之内的1只怪兽当作装备卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4837861,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetTarget(c4837861.eqtg)
	e3:SetOperation(c4837861.eqop)
	c:RegisterEffect(e3)
	-- ③：有同调怪兽装备的这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c4837861.pcon)
	e4:SetValue(2)
	c:RegisterEffect(e4)
end
-- 筛选自己墓地中满足条件的「机皇」怪兽：属于「机皇」字段、是怪兽卡，且可以除外作为召唤代价。
function c4837861.spfilter(c)
	return c:IsSetCard(0x13) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则条件：自己场上主要怪兽区有空位，且墓地中可作为除外代价的「机皇」怪兽有不同的卡名种类数≥3，即满足“3种类各1只”。
function c4837861.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的主要怪兽区空格；若无空格，则无法进行该特殊召唤。
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 取得自己墓地中所有可作为除外代价的「机皇」怪兽组成的集合，用于后续选择。
	local g=Duel.GetMatchingGroup(c4837861.spfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>=3
end
-- 特殊召唤的素材选择处理：从墓地的「机皇」怪兽中选出3张卡名互不相同的卡（3种类各1只），保存选择结果并返回true；若无法选出则返回false。
function c4837861.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己墓地中所有可作为除外代价的「机皇」怪兽，作为选择素材的候选池。
	local g=Duel.GetMatchingGroup(c4837861.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置临时附加检查条件：所选卡片的卡名必须互不相同，以满足“3种类”的要求。
	aux.GCheckAdditional=aux.dncheck
	-- 从候选「机皇」怪兽中选择3张卡名互不相同的卡（3种类各1只）作为除外代价；选择成功则返回这组卡。
	local rg=g:SelectSubGroup(tp,aux.TRUE,true,3,3)
	-- 清除附加的卡名互不相同检查，避免影响后续其他选择。
	aux.GCheckAdditional=nil
	if rg then
		rg:KeepAlive()
		e:SetLabelObject(rg)
		return true
	else return false end
end
-- 特殊召唤处理：取出之前选择的3张「机皇」怪兽，将其从墓地除外，完成召唤代价。
function c4837861.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=e:GetLabelObject()
	-- 将选择的3张「机皇」怪兽以表侧表示除外，作为特殊召唤的代价。
	Duel.Remove(rg,POS_FACEUP,REASON_SPSUMMON)
	rg:DeleteGroup()
end
-- 装备卡合法性过滤器：检查额外卡组中的怪兽是否不能被作为装备卡使用（IsForbidden），以及是否满足场上同名卡唯一规则，确保可以装备到自己的魔陷区。
function c4837861.eqfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 发动条件用过滤器：额外卡组中存在里侧表示的卡（通常额外卡组均为里侧），或者存在可通过eqfilter判定为可装备的卡；用于确认有可选的装备对象。
function c4837861.filter(c,tp)
	return c:IsFacedown() or c4837861.eqfilter(c,tp)
end
-- ①效果发动条件：自己魔陷区有空位、对方额外卡组有卡，并且其中存在至少1张可装备的怪兽。
function c4837861.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得对方额外卡组的全部卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 在发动时点检查：魔陷区有空位、对方额外卡组非空，且存在满足装备条件的卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetCount()>0
		and g:IsExists(c4837861.filter,1,nil,tp) end
end
-- ①效果处理：确认魔陷区空格且本卡仍表侧、与效果关联；展示对方额外卡组；选择1只怪兽装备给本卡；装备成功后为该装备卡设置装备限制和攻击力上升效果；最后洗切对方额外卡组。
function c4837861.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前合法性检查：若魔陷区无空位、本卡已里侧或与本效果无关，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 取得对方额外卡组的全部卡片，用于展示与选择。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 向当前玩家展示对方额外卡组的全部卡片。
	Duel.ConfirmCards(tp,g,true)
	-- 显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	local sg=g:FilterSelect(tp,c4837861.eqfilter,1,1,nil,tp)
	local tc=sg:GetFirst()
	if tc then
		-- 尝试将选中的怪兽作为装备卡装备给本卡；装备成功才继续后续处理。
		if Duel.Equip(tp,tc,c) then
			local atk=tc:GetTextAttack()
			-- 选那之内的1只怪兽当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c4837861.eqlimit)
			tc:RegisterEffect(e1)
			if atk>0 then
				-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(atk)
				tc:RegisterEffect(e2)
			end
		end
	end
	-- 洗切对方额外卡组，因为展示并选择了其中的卡片。
	Duel.ShuffleExtra(1-tp)
end
-- 装备限制函数：该装备卡只能装备给效果的所有者（即机皇神龙），防止装备对象改变。
function c4837861.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤本卡装备的怪兽卡中，是否存在表侧表示且原本种类包含同调怪兽的卡。
function c4837861.xatkfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_SYNCHRO~=0
end
-- ③效果条件：本卡所装备的怪兽中存在同调怪兽时，追加攻击效果才适用。
function c4837861.pcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(c4837861.xatkfilter,1,nil)
end
