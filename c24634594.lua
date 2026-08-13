--魔螂ディアボランティス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的昆虫族·植物族怪兽从卡组送去墓地。
-- ②：这张卡是已同调召唤的场合，以自己场上1只昆虫族·植物族怪兽为对象才能发动。那只怪兽直到回合结束时变成调整。
local s,id,o=GetID()
-- 初始化效果注册：先设定苏生限制与同调召唤条件，再创建①的诱发送墓效果及素材数量记录效果，最后创建②的起动变调整效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定同调召唤手续：需要调整＋调整以外的怪兽1只以上（即1只调整+任意数量非调整）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡同调召唤的场合才能发动。把最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的昆虫族·植物族怪兽从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- 那些作为同调素材的怪兽之内除调整以外的怪兽数量
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	-- ②：这张卡是已同调召唤的场合，以自己场上1只昆虫族·植物族怪兽为对象才能发动。那只怪兽直到回合结束时变成调整。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.tntg)
	e2:SetOperation(s.tnop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡的召唤方式为同调召唤（e:GetHandler()即这张卡，IsSummonType检查召唤类型为SUMMON_TYPE_SYNCHRO）。①②效果共用此条件。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤函数：用于选择昆虫族或植物族的怪兽，且能够被送去墓地（IsAbleToGrave）。
function s.filter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsAbleToGrave()
end
-- ①效果的目标与发动条件：读取记录的非调整素材数量ct；在发动时确认ct>0且卡组存在可送墓的昆虫族·植物族怪兽，并设置“从卡组送去墓地”的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 发动时点检查：记录的非调整素材数量ct必须大于0，且卡组中存在至少1只昆虫族·植物族怪兽可以被送去墓地。
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本次效果处理为“从卡组把卡送去墓地”（CATEGORY_TOGRAVE），目标位置为卡组、目标玩家为tp，预计处理数量为1（实际数量以处理时选择为准）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1～e:GetLabel()（记录的非调整素材数量）张昆虫族·植物族怪兽，然后将其送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 执行选卡：从卡组选择1～e:GetLabel()张符合s.filter的昆虫族·植物族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,e:GetLabel(),nil)
	-- 将选出的卡以效果原因（REASON_EFFECT）送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 素材数量记录函数：在该卡作为同调素材时被调用，通过素材总数减去1（唯一的调整）得到调整以外的素材数量，并将这个数量写到①效果e1的Label上，供发动时作为最多送墓数量。
function s.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterialCount()-1)
end
-- ②效果对象过滤：表侧表示、昆虫族或植物族、且不是调整的怪兽。
function s.tfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT) and not c:IsType(TYPE_TUNER)
end
-- ②效果的目标设定：若是再确认对象（chkc），检查该卡是否在自己场上且符合s.tfilter；在发动时检查是否存在符合条件的对象；提示玩家并选择1只作为效果对象。
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc) end
	-- 发动检查：自己场上是否存在1只符合s.tfilter的对象。
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的自己场上的昆虫族·植物族非调整怪兽作为对象（Duel.SelectTarget同时登记为效果对象）。
	Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：若对象仍与效果相关且为表侧表示，则给对象怪兽赋予“调整”种类，直到回合结束时有效。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果处理时的对象卡（这里只有1张对象，所以用GetFirstTarget获取）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时变成调整。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
