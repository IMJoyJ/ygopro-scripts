--魔螂ディアボランティス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的昆虫族·植物族怪兽从卡组送去墓地。
-- ②：这张卡是已同调召唤的场合，以自己场上1只昆虫族·植物族怪兽为对象才能发动。那只怪兽直到回合结束时变成调整。
local s,id,o=GetID()
-- 初始化效果，设置该卡的同调召唤手续并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
	-- 检查同调素材数量并记录到e1的标签中
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
-- 判断该卡是否为同调召唤
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的昆虫族·植物族怪兽
function s.filter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsAbleToGrave()
end
-- 设置效果处理时要送去墓地的卡组中的昆虫族·植物族怪兽数量
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 检查是否满足发动条件，即有可选的昆虫族·植物族怪兽
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡组中送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果，选择并把符合条件的卡从卡组送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡组中的昆虫族·植物族怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,e:GetLabel(),nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 记录同调素材中除调整外的怪兽数量
function s.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterialCount()-1)
end
-- 过滤满足条件的表侧表示的昆虫族·植物族怪兽
function s.tfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT) and not c:IsType(TYPE_TUNER)
end
-- 设置效果处理时要选择的目标怪兽
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc) end
	-- 检查是否满足发动条件，即场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的场上怪兽作为目标
	Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果，将目标怪兽变为调整
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给目标怪兽添加调整属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
