--ドラグニティ－プリムス・ピルス
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时，以自己场上1只鸟兽族「龙骑兵团」怪兽为对象才能发动。从卡组选1只龙族·3星以下的「龙骑兵团」怪兽当作装备卡使用给作为对象的怪兽装备。
function c18060565.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时，以自己场上1只鸟兽族「龙骑兵团」怪兽为对象才能发动。从卡组选1只龙族·3星以下的「龙骑兵团」怪兽当作装备卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18060565,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c18060565.eqtg)
	e1:SetOperation(c18060565.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 筛选表侧表示、鸟兽族且卡名含有「龙骑兵团」字段的我方场上怪兽，作为“以自己场上1只鸟兽族「龙骑兵团」怪兽为对象”的对象候选。
function c18060565.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsRace(RACE_WINDBEAST)
end
-- 效果的目标检测与对象选择函数：在连锁确认对象时验证对象位于我方主要怪兽区且满足filter；在发动判定时检查魔陷区有空位、存在符合条件的对象怪兽以及卡组存在符合条件的龙族3星以下「龙骑兵团」怪兽。
function c18060565.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18060565.filter(chkc) end
	-- 效果发动条件之一：我方魔陷区必须存在至少1个空位，用于后续把卡组选出的怪兽装备到对象上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 效果发动条件之二：我方主要怪兽区存在至少1只表侧表示、鸟兽族且为「龙骑兵团」的怪兽可作为取对象的目标。
		and Duel.IsExistingTarget(c18060565.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果发动条件之三：我方卡组存在至少1张符合条件的龙族·3星以下「龙骑兵团」怪兽，可供效果处理时选择并当作装备卡使用。
		and Duel.IsExistingMatchingCard(c18060565.eqfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向操作玩家显示选择提示，提示其选择表侧表示的怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从我方场上的表侧鸟兽族「龙骑兵团」怪兽中选择1只作为效果对象，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,c18060565.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义从卡组选择装备卡的筛选条件：卡名含有「龙骑兵团」字段、龙族、等级3以下，且未被禁止作为装备卡使用。
function c18060565.eqfilter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(3) and not c:IsForbidden()
end
-- 效果处理函数：先确认魔陷区有空位，再取得对象；确认对象仍与效果相关且表侧表示后，从卡组选出符合条件的「龙骑兵团」怪兽；若成功将其装备给对象，则为该装备卡附加只能装备给该对象的限制。
function c18060565.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时的再次判定：若我方魔陷区没有空位，则无法进行装备，效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 取出效果发动时选择的对象怪兽（作为装备卡的装备对象）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向操作玩家显示选择提示，提示其从卡组选择要当作装备卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从我方卡组选择1张符合条件的「龙骑兵团」怪兽，作为将要装备给对象的装备卡。
	local eq=Duel.SelectMatchingCard(tp,c18060565.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
	local eqc=eq:GetFirst()
	-- 若选出的装备卡存在，且成功通过Duel.Equip将其装备给对象怪兽，则进入后续给装备卡设置装备限制的处理。
	if eqc and Duel.Equip(tp,eqc,tc) then
		-- 从卡组选1只龙族·3星以下的「龙骑兵团」怪兽当作装备卡使用给作为对象的怪兽装备。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c18060565.eqlimit)
		e1:SetLabelObject(tc)
		eqc:RegisterEffect(e1)
	end
end
-- 装备限制函数：只有登记的对象怪兽（e:GetLabelObject()）才能装备这张装备卡，确保选出的「龙骑兵团」怪兽只会被装备给当初选择的对象。
function c18060565.eqlimit(e,c)
	return c==e:GetLabelObject()
end
