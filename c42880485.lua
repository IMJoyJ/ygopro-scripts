--超重輝将ヒス－E
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「超重武者」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，以自己场上1只「超重武者」怪兽为对象才能发动。那只怪兽的等级上升1星。
-- 【怪兽效果】
-- 这张卡在规则上也当作「超重武者」卡使用。这张卡可以把1只「超重武者」怪兽解放作上级召唤。
-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
function c42880485.initial_effect(c)
	-- 为这张卡注册灵摆怪兽的基本属性，使其可以作为灵摆召唤/灵摆卡发动，并处理灵摆区的相关规则。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「超重武者」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c42880485.splimcon)
	e2:SetTarget(c42880485.splimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只「超重武者」怪兽为对象才能发动。那只怪兽的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c42880485.lvtg)
	e3:SetOperation(c42880485.lvop)
	c:RegisterEffect(e3)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetTarget(c42880485.postg)
	e4:SetOperation(c42880485.posop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	-- 这张卡可以把1只「超重武者」怪兽解放作上级召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(42880485,0))  --"把1只「超重武者」怪兽解放作上级召唤"
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SUMMON_PROC)
	e6:SetCondition(c42880485.otcon)
	e6:SetOperation(c42880485.otop)
	e6:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e7)
	-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_DEFENSE_ATTACK)
	e8:SetValue(1)
	c:RegisterEffect(e8)
end
-- 该效果的发动条件：这张卡在灵摆区且没有被无效（不是处于禁止使用的状态），即灵摆限制效果仅在灵摆区有效且可发动。
function c42880485.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
-- 灵摆召唤限制的判定：被灵摆召唤的怪兽不是「超重武者」时，禁止该灵摆召唤；即只有「超重武者」怪兽才能进行灵摆召唤。
function c42880485.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x9a) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 升星效果的对象过滤条件：表侧表示、属于「超重武者」系列且等级大于0的怪兽。
function c42880485.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a) and c:GetLevel()>0
end
-- 升星效果的发动条件和对象指定：检查能否取对象（自己场上符合条件的「超重武者」怪兽），并让玩家选择1只作为对象。
function c42880485.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42880485.filter(chkc) end
	-- 发动条件判定：确认自己场上是否存在至少1只符合条件的「超重武者」表侧表示怪兽作为升星对象。
	if chk==0 then return Duel.IsExistingTarget(c42880485.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给操作玩家发送选择对象的提示消息，显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「超重武者」怪兽，并登记为本次效果的对象。
	Duel.SelectTarget(tp,c42880485.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 升星效果的处理：取得对象怪兽，若它仍与此效果关联且表侧表示，则给它添加一个等级+1的效果，持续到离场等标准重置时机。
function c42880485.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一张对象卡，即被选择升星的「超重武者」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 表示形式变更效果的发动条件（召唤成功时）与操作信息登记：满足发动条件，并告知系统本效果将改变这张卡的表示形式。
function c42880485.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，将本次效果类别登记为改变表示形式（CATEGORY_POSITION），目标为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 表示形式变更效果的处理：若这张卡仍与效果关联，则改变其表示形式——表侧攻击变为表侧守备，表侧守备变为表侧攻击，其他形式改为表侧攻击。
function c42880485.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 实际执行表示形式变更：按指定形式改变这张卡的表示形式。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 上级召唤解放素材的过滤条件：属于「超重武者」系列，并且是自己场上的怪兽，或者是对方场上表侧表示的怪兽（即自己场上的超重武者或对方表侧表示的超重武者可作为解放素材）。
function c42880485.otfilter(c,tp)
	return c:IsSetCard(0x9a) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤规则效果的条件：这张卡等级在7以上、需要的解放数不超过1，并且存在符合条件解放素材。
function c42880485.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取所有可作为解放素材的「超重武者」怪兽组（包括自己场上所有超重武者和对方场上表侧表示的超重武者）。
	local mg=Duel.GetMatchingGroup(c42880485.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤条件：这张卡等级≥7、所需解放怪兽数量≤1，且存在至少1只可解放的素材。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤处理：选择1只符合条件的「超重武者」怪兽作为解放素材，将其作为这张卡的素材并解放，完成上级召唤手续。
function c42880485.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取所有可作为解放素材的「超重武者」怪兽组，供玩家选择解放。
	local mg=Duel.GetMatchingGroup(c42880485.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从符合条件的素材中选择1只怪兽作为上级召唤的解放。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的素材解放（作为召唤代价）送入墓地。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
