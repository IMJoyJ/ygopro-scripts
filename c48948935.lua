--仮面魔獣デス・ガーディウス
-- 效果：
-- 这张卡不能通常召唤。把包含「假面咒术师 诅咒之喉」「梅尔基多四面兽」之内任意种的自己场上2只怪兽解放的场合可以特殊召唤。
-- ①：这张卡从场上送去墓地的场合，以对方场上1只表侧表示怪兽为对象发动。从卡组把1张「遗言之假面」当作装备卡使用给作为对象的怪兽装备。
function c48948935.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把包含「假面咒术师 诅咒之喉」「梅尔基多四面兽」之内任意种的自己场上2只怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c48948935.spcon)
	e1:SetTarget(c48948935.sptg)
	e1:SetOperation(c48948935.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡从场上送去墓地的场合，以对方场上1只表侧表示怪兽为对象发动。从卡组把1张「遗言之假面」当作装备卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48948935,0))  --"装备"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c48948935.eqcon)
	e2:SetTarget(c48948935.eqtg)
	e2:SetOperation(c48948935.eqop)
	c:RegisterEffect(e2)
end
-- 特殊召唤手续的怪兽组筛选函数：在玩家选择的2只解放怪兽中，至少包含「假面咒术师 诅咒之喉」或「梅尔基多四面兽」之一，并通过aux.mzctcheckrel确认解放这些怪兽后主怪兽区仍有空位且它们能够被解放。
function c48948935.fselect(g,tp)
	-- 检查解放组g中是否存在卡号为13676474（假面咒术师 诅咒之喉）或86569121（梅尔基多四面兽）的怪兽，同时调用aux.mzctcheckrel确认解放后主怪兽区仍有空位且怪兽可正常解放，两者都满足才返回true。
	return g:IsExists(Card.IsCode,1,nil,13676474,86569121) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 特殊召唤手续的条件判定：若c为空（规则询问）直接允许；否则获取控制者tp可解放的怪兽组，检查其中是否存在满足fselect条件的2只怪兽，以此判断能否通过解放2只包含指定怪兽的怪兽来特殊召唤这张卡。
function c48948935.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家tp可用于特殊召唤解放的怪兽组（不含手卡，解放原因为REASON_SPSUMMON），作为后续筛选的对象池。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return rg:CheckSubGroup(c48948935.fselect,2,2,tp)
end
-- 特殊召唤手续的目标选择：从可解放怪兽组中让玩家选择2只满足fselect条件的怪兽作为解放代价；选择成功后用KeepAlive保持该组不被回收，并保存到效果的LabelObject中供后续解放使用，同时返回true表示手续成立。
function c48948935.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家tp可用于特殊召唤解放的怪兽组（不含手卡，解放原因为REASON_SPSUMMON），作为玩家选择的候选集合。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家发送“请选择要解放的卡”的消息提示，用于配合后续的怪兽选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c48948935.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的执行操作：取出之前保存的怪兽组g，将g中的怪兽解放（解放原因为特殊召唤），然后删除保存的组对象，完成特殊召唤的代价处理。
function c48948935.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将之前选择的怪兽组g以REASON_SPSUMMON原因解放，作为这张卡特殊召唤的解放代价。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的发动条件：确认触发效果时这张卡是从场上被送去墓地（即之前位于场上区域），满足“这张卡从场上送去墓地的场合”的要求。
function c48948935.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ①效果的取对象处理：连锁确认时检查对象是否为对方场上的表侧表示怪兽；发动时无条件成立，并提示玩家选择对方场上1只表侧表示怪兽作为效果对象。
function c48948935.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 向玩家发送“请选择表侧表示的卡”的消息提示，用于选择对方场上表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只表侧表示怪兽，并将其设置为当前连锁的效果对象（即效果指定的“对方场上1只表侧表示怪兽”）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备卡的检索过滤器：筛选卡组中卡号为22610082的「遗言之假面」，且该卡不是禁止卡。
function c48948935.filter(c)
	return c:IsCode(22610082) and not c:IsForbidden()
end
-- ①效果处理操作：先检查自己魔陷区是否还有空位；若有，则取得之前选择的对象，确认其仍表侧且与效果关联后，从卡组选择1张「遗言之假面」，通过Duel.Equip将其装备给对象，再为装备卡设置只能装备给该对象的限制以及获得对象控制权的效果。
function c48948935.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己魔陷区是否有可用空格来放置装备卡；若没有空位则直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 取得效果发动时选择的目标怪兽（对方场上的表侧表示怪兽），作为后续装备的对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 向玩家发送“请选择要装备的卡”的消息提示，配合从卡组选择「遗言之假面」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己卡组中选择1张满足filter条件的「遗言之假面」（即卡号22610082且非禁止卡），作为要装备的卡片。
		local g=Duel.SelectMatchingCard(tp,c48948935.filter,tp,LOCATION_DECK,0,1,1,nil)
		local eqc=g:GetFirst()
		-- 若没有成功选出装备卡，或Duel.Equip未能将选出的「遗言之假面」装备给对象怪兽，则结束效果处理；否则继续执行后续的装备限制和控制权设定。
		if not eqc or not Duel.Equip(tp,eqc,tc) then return end
		-- 给作为对象的怪兽装备。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c48948935.eqlimit)
		e1:SetLabelObject(tc)
		eqc:RegisterEffect(e1)
		-- ②：这张卡用「假面魔兽 死亡护法师」的效果装备中的场合，得到装备怪兽的控制权。
		local e2=Effect.CreateEffect(eqc)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		eqc:RegisterEffect(e2)
	end
end
-- 装备限制判定函数：只有装备目标等于该效果LabelObject中保存的怪兽（即当初选择的对象）时才允许装备，确保这张「遗言之假面」只能装备给效果指定的对象怪兽。
function c48948935.eqlimit(e,c)
	return e:GetLabelObject()==c
end
