--ヴァイロン・シグマ
-- 效果：
-- 光属性调整＋调整以外的光属性怪兽1只以上
-- 自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击宣言时才能发动。从自己卡组选择1张装备魔法卡给这张卡装备。
function c48370501.initial_effect(c)
	-- 为这张卡添加同调召唤手续，对应素材条件“光属性调整＋调整以外的光属性怪兽1只以上”：调整必须是光属性，非调整也必须是光属性且至少1只。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1)
	c:EnableReviveLimit()
	-- 自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击宣言时才能发动。从自己卡组选择1张装备魔法卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48370501,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c48370501.eqcon)
	e1:SetTarget(c48370501.eqtg)
	e1:SetOperation(c48370501.eqop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：用于判断“自己场上没有这张卡以外的怪兽存在”这一发动条件是否成立。
function c48370501.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上怪兽区卡数不超过1，即自己场上没有这张卡以外的怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
-- 定义装备魔法卡的过滤函数：该卡必须是装备魔法卡，并且能够装备给这张卡自身（ec为这张卡）。
function c48370501.filter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 定义效果发动时的Target函数（合法性检测）：在chk==0时确认可以发动，即自己魔陷区有空位，且卡组中存在可以装备给这张卡的装备魔法卡。
function c48370501.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0表示发动时检查，确认自己魔陷区有空闲区域可放置装备魔法卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 同时检查卡组中是否存在至少1张满足过滤条件且能装备给这张卡的装备魔法卡。
		and Duel.IsExistingMatchingCard(c48370501.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
end
-- 定义效果处理函数：实际执行从卡组挑选装备魔法卡并装备给这张卡的操作。
function c48370501.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认条件：若魔陷区已无空位、这张卡变为里侧表示，或这张卡已与效果失去关联，则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家发出选择提示消息，提示其从卡组选择一张装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48370501,1))  --"请选择一张装备魔法卡"
	-- 从卡组中选择1张满足条件的装备魔法卡（filter以这张卡作为额外参数，确保装备对象正确）。
	local g=Duel.SelectMatchingCard(tp,c48370501.filter,tp,LOCATION_DECK,0,1,1,nil,c)
	if g:GetCount()>0 then
		-- 将选择的装备魔法卡装备给这张卡。
		Duel.Equip(tp,g:GetFirst(),c)
	end
end
