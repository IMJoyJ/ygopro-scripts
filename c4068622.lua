--BF－極光のアウロラ
-- 效果：
-- 这张卡不能通常召唤。把自己场上表侧表示存在的1只名字带有「黑羽」的调整和1只调整以外的怪兽从游戏中除外的场合才能特殊召唤。1回合1次，可以从自己的额外卡组把1只名字带有「黑羽」的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同的攻击力和效果。
function c4068622.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己场上表侧表示存在的1只名字带有「黑羽」的调整和1只调整以外的怪兽从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c4068622.spcon)
	e1:SetTarget(c4068622.sptg)
	e1:SetOperation(c4068622.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从自己的额外卡组把1只名字带有「黑羽」的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同的攻击力和效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4068622,0))  --"获得怪物效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c4068622.target)
	e2:SetOperation(c4068622.operation)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定恒设为false，使这张卡无法被常规的特殊召唤方式出场，只能通过上述自定义特殊召唤手续（e1）进行特殊召唤。
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤素材的通用条件：怪兽必须表侧表示，并且可以作为COST从游戏中除外。
function c4068622.spfilter(c)
	return c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
-- 定义素材的选择条件之一：该怪兽必须是名字带有「黑羽」的调整怪兽。
function c4068622.spfilter1(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_TUNER)
end
-- 定义素材的选择条件之二：该怪兽必须是调整以外的怪兽。
function c4068622.spfilter2(c)
	return not c:IsType(TYPE_TUNER)
end
-- 用于从候选组中选出2张素材，要求除外后仍有可用怪兽区空格，且两张卡分别满足“黑羽调整”和“调整以外”的素材要求。
function c4068622.fselect(g,tp)
	-- 判定素材组是否合法：除外后场上仍留有可用怪兽区空格，且两张卡能分别匹配黑羽调整与调整以外的组合条件。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,c4068622.spfilter1,nil,c4068622.spfilter2,nil)
end
-- 特殊召唤手续的发动条件：确认从自己场上表侧表示怪兽中存在满足条件的2张素材，可用于规则特殊召唤。
function c4068622.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得自己场上所有满足条件的表侧表示且可作COST除外的怪兽，作为特殊召唤素材的候选集合。
	local g=Duel.GetMatchingGroup(c4068622.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c4068622.fselect,2,2,tp)
end
-- 选择特殊召唤素材的阶段：让玩家从候选集合中选出2张合法素材，并将选中的素材组保存到效果中，供后续除外使用。
function c4068622.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上可作为COST除外的表侧表示怪兽集合，供玩家选择特殊召唤素材。
	local g=Duel.GetMatchingGroup(c4068622.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 弹出“请选择要除外的卡”的提示信息，引导玩家选择要作为COST除外的素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c4068622.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤手续：从效果中取出先前选择的素材组，将其除外，然后完成规则特殊召唤。
function c4068622.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的素材组从游戏中以表侧表示除外，除外原因记为特殊召唤（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义起动效果可选择的对象：额外卡组中名字带有「黑羽」且能被除外的怪兽。
function c4068622.filter(c)
	return c:IsSetCard(0x33) and c:IsAbleToRemove()
end
-- 起动效果的目标处理：检查额外卡组是否存在符合条件的「黑羽」怪兽，并登记将除外的操作信息。
function c4068622.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：若额外卡组没有符合条件的「黑羽」怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4068622.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 登记操作信息：本次效果将涉及除外自己的额外卡组中的卡片，对象在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择1只「黑羽」怪兽除外；成功后复制该怪兽的卡名、攻击力和效果，并设置结束阶段复原。
function c4068622.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的额外卡组卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的额外卡组选择1张满足条件的「黑羽」怪兽作为除外对象。
	local g=Duel.SelectMatchingCard(tp,c4068622.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 确认对象卡存在、本卡仍表侧表示且与效果关联，且除外操作成功，才继续执行复制效果。
	if tc and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local code=tc:GetOriginalCode()
		local ba=tc:GetBaseAttack()
		-- 直到结束阶段时当作和那只怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		-- 得到相同的攻击力
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e2:SetValue(ba)
		c:RegisterEffect(e2)
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 直到结束阶段时，得到相同的效果
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(1162)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCountLimit(1)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetLabel(cid)
		e3:SetLabelObject(e2)
		e3:SetOperation(c4068622.rstop)
		c:RegisterEffect(e3)
	end
end
-- 结束阶段时的复位处理：清除复制的效果、卡名变更与攻击力变化，使这张卡恢复原状。
function c4068622.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e2=e:GetLabelObject()
	local e1=e2:GetLabelObject()
	e1:Reset()
	e2:Reset()
	-- 手动展示这张卡的卡片动画，提示其复制效果被解除。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示本卡复制的效果在结束阶段结束/重置。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
