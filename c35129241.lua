--星屑の願い
-- 效果：
-- ①：1回合1次，自己场上的「星尘」同调怪兽为让自身的效果发动而被解放的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：这张卡的①的效果特殊召唤的怪兽在攻击表示的场合不会被战斗破坏。
function c35129241.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的「星尘」同调怪兽为让自身的效果发动而被解放的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetTarget(c35129241.target)
	e2:SetOperation(c35129241.activate)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果特殊召唤的怪兽在攻击表示的场合不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c35129241.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 筛选解放的怪兽：其原控制者为自己、原位置在主要怪兽区、属于「星尘」字段、是同步怪兽、解放原因是作为代价而解放、且正是为了发动自身效果而被解放的怪兽（即与诱发效果的re处理者是同一只），同时该怪兽能成为效果对象且能被特殊召唤。
function c35129241.filter(c,e,tp,re)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSetCard(0xa3) and c:IsType(TYPE_SYNCHRO) and c:IsReason(REASON_COST) and c==re:GetHandler()
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时先确认是否存在满足过滤条件的解放怪兽，且自己场上主要怪兽区有空位；该条件满足时才允许发动。
function c35129241.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:IsExists(c35129241.filter,1,nil,e,tp,re)
		-- 追加检查自己场上主要怪兽区是否有可用空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local tg
	if #eg==1 then
		tg=eg:Clone()
	else
		-- 提示发动玩家选择效果对象，显示“请选择效果的对象”的选择消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tg=eg:FilterSelect(tp,c35129241.filter,1,1,nil,e,tp,re)
	end
	-- 把选择到的卡设为当前连锁的效果对象（即广义对象），使该卡与效果建立联系。
	Duel.SetTargetCard(tg)
	-- 设置操作信息，向系统声明本效果将进行特殊召唤，对象为tg，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
	-- 设置连锁限制：本效果发动后，只允许发动者自己进行连锁，以封住对方对应此效果发动卡牌的机会。
	Duel.SetChainLimit(c35129241.chlimit)
end
-- 连锁限制判定函数：只有当尝试连锁的玩家ep是效果发动者tp时返回真，即对方玩家不能连锁发动魔法·陷阱·怪兽效果。
function c35129241.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果处理时，获取之前选择的对象怪兽，若该怪兽与效果仍有关联则将其表侧表示特殊召唤到自己场上；成功后给该怪兽注册一个标识效果，记录其是由这张卡的①效果特殊召唤的，以供②效果识别。
function c35129241.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个效果对象（即被解放并选为对象的「星尘」同调怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查该对象是否仍然与效果相关（未被移离或失效），然后尝试以正面表示特殊召唤它；若特殊召唤成功则执行then分支。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		tc:RegisterFlagEffect(35129241,RESET_EVENT+RESETS_STANDARD,0,1,e:GetHandler():GetFieldID())
	end
end
-- ②效果的对象判定：怪兽为攻击表示，并且带有由这张卡①效果特殊召唤时注册的标识（标识数值等于这张卡的当前场地区域标识），则适用不会被战斗破坏。
function c35129241.indtg(e,c)
	return c:IsAttackPos() and c:GetFlagEffectLabel(35129241)==e:GetHandler():GetFieldID()
end
